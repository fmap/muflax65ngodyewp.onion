#!/usr/bin/env python3
# Copyright muflax <mail@muflax.com>, 2010
# License: GNU GPL 3 <http://www.gnu.org/copyleft/gpl.html>

import datetime as dt
import glob
import hashlib
import optparse
import os
import os.path as op
import re
import shutil
import subprocess
import sys

import PyRSS2Gen as RSS2
import clevercss
import yaml
try:
    from yaml import CLoader as Loader
except ImportError:
    from yaml import Loader

class Webifier(object):
    """turn source files into static website"""
    def __init__(self, src, out, styles, layout, force):
        self.src = src
        self.src = src
        self.styles = styles
        self.layout = layout
        self.force = force
        self.out = out
        self.now = dt.datetime.now()
    def webify(self):
        """wrapper for the whole process"""
            
        self.make_html_files(self.src, self.out)
        self.make_css(self.styles, op.join(self.out, self.styles))
        self.tidy_up_html(self.out)
        self.make_rss_feed(op.join(self.out, "changelog.html"))
        self.tidy_up_xml(self.out)
        self.copy_media_files(self.src, self.out)

    def copy_media_files(self, src, out):
        """copy all the other files, like images"""
        # again, we manually walk this shit... *sigh*
        for f in [f for f in os.listdir(src)
                  if (op.isfile(op.join(src, f))
                      and not re.search("\.(yaml|pdc)$", f))]:
            shutil.copy2(op.join(src, f), op.join(out, f))
            
        for dir in [d for d in os.listdir(src) 
                    if op.isdir(op.join(src, d))]:
            self.copy_media_files(src=op.join(src, dir), 
                                  out=op.join(out, dir))

    def _breadcrumbtagify(self, file, name=None, depth=0):
        """turn an address and name into a proper link"""
        if not name:
            name = file
        
        if depth > 1:
            file = "../" * (depth - 1)
        elif depth == 1:
            file = "./"
        
        r = "<a href='{}' class='crumb'>{}</a>".format(file, name)
        return r

    def make_breadcrumb(self, file, meta):
        """turn current path into breadcrumb navigation""" 
        crumbs = []
        depth = len(meta["cats"])
        for catfile, cat in meta["cats"]:
            crumbs.append(self._breadcrumbtagify(catfile, cat, depth=depth))
            depth -= 1
        
        crumbs.append(self._breadcrumbtagify(op.basename(file), "<>"))
        return " &#187; ".join(crumbs)

    def templatify(self, file, meta, out):
        """templatify file using meta and save it at out"""
        print("\ttemplatifying {}...".format(file))
        dest = op.join(out, op.basename(file).replace(".pdc", ".html"))
        breadcrumb = self.make_breadcrumb(dest, meta)
        
        pandoc = ["pandoc",
                  "--template", op.join("layout", meta["layout"]),
                  "--css", op.join("style", meta["style"]),
                  "--variable", "breadcrumb:{}".format(breadcrumb),
                  "-o", dest,
                  file
                 ]
        subprocess.call(pandoc)
        print("\t\tsaving as {}...".format(dest))

    def make_html_files(self, src, out, meta=None):
        """turn all *.pdc in src into html files in out"""
        
        # we'll have to manually walk this shit...
        # read the metadata and update the old one   
        meta = {} if meta == None else meta.copy() 
        print("reading metadata in {}...".format(src))
        meta_file = op.join(src, "meta.yaml")
        with open(meta_file, "r") as f:
            data = yaml.load(f, Loader=Loader)
            meta.update(data)

        # add breadcrumb information to metadata
        if "cats" in meta:
            crumb = (op.basename(out), meta["title"])
            meta["cats"].append(crumb)
        else: # root path, needs to be renamed
            crumb = ("", meta["title"])
            meta["cats"] = [crumb]
            
        # templatify all files here
        if not op.exists(out):
            os.mkdir(out)
        for f in glob.glob(src+"/*.pdc"):
            mtime = dt.datetime.fromtimestamp(os.stat(f).st_mtime)
            if self.force or mtime > self.now:
                self.templatify(f, meta, out)
        
        # do the same for all subdirectories 
        for dir in [d for d in os.listdir(src) 
                    if op.isdir(op.join(src, d))]:
            self.make_html_files(src=op.join(src, dir), 
                                 out=op.join(out, dir),
                                 meta=meta)

    def make_css(self, src, out):
        """turn clevercss templates into proper css"""
        if not op.exists(out):
            os.mkdir(out)
        for f in glob.glob(op.join(src, "*.clevercss")):
            mtime = dt.datetime.fromtimestamp(os.stat(f).st_mtime)
            if self.force or mtime > self.now:
                print("cssifying {}...".format(f))
                with open(f, "r") as clever_f:
                    conv = clevercss.convert(clever_f.read())
                dest = op.join(out, op.basename(f).replace(".clevercss",
                                                           ".css"))
                with open(dest, "w") as css_f:
                    print("\tsaving as {}...".format(dest))
                    css_f.write(conv)

    def make_rss_feed(self, changelog):
        """generate an RSS feed out of the Changelog"""

        mtime = dt.datetime.fromtimestamp(os.stat(changelog).st_mtime)
        if not (self.force or mtime > self.now):
            return
            
        with open(changelog, "r") as f:
            print("parsing {}...".format(changelog))
            txt = f.read()
        relist = re.compile("""
                            <li>
                            (?P<y>\d+) / (?P<m>\d+) / (?P<d>\d+):\ 
                            (?P<desc>.+?)
                            </li>
                            """, re.X|re.S)
            
        items = []
        for entry in relist.finditer(txt):
            items.append(
                RSS2.RSSItem(
                    title = "omg new stuff!!w!",
                    link = "http://www.muflax.com/changelog.html",
                    description = entry.group("desc"),
                    pubDate = dt.datetime(
                        int(entry.group("y")),
                        int(entry.group("m")),
                        int(entry.group("d"))
                    ),
                    guid = RSS2.Guid(
                        hashlib.md5(entry.group("desc").encode("utf8")).hexdigest()
                    )
                )
            )
        
        if not items:
            print("RSS broke... again...")
            sys.exit(1)

        feed = RSS2.RSS2(
            title = "muflax.com",
            link = "http://www.muflax.com",
            description = "lies and wonderland",
            lastBuildDate = dt.datetime.now(),
            items = items[:10]
        )

        with open("out/rss.xml", "w") as f:
            print("writing RSS feed...")
            feed.write_xml(f, encoding="utf8")

    def tidy_up_html(self, dir):
        """clean up all the html we generated earlier..."""

        for root, dirs, files in os.walk(dir):
            for f in [op.join(root, f) for f in files 
                      if re.match(".*\.html", f)]:
                mtime = dt.datetime.fromtimestamp(os.stat(f).st_mtime)
                if self.force or mtime > self.now:
                    subprocess.call(["tidy", "-i", "--tidy-mark", "f", "-m", "-q",
                                     "-utf8", f])

    def tidy_up_xml(self, dir):
        """clean up all the xml we generated earlier..."""
        
        for root, dirs, files in os.walk(dir):
            for f in [op.join(root, f) for f in files 
                      if re.match(".*\.xml", f)]:
                mtime = dt.datetime.fromtimestamp(os.stat(f).st_mtime)
                if self.force or mtime > self.now:
                    subprocess.call(["tidy", "-i", "-xml", "-m", "-q", "-utf8", f])

def main():
    parser = optparse.OptionParser()
    parser.add_option("-f", "--force", dest="force", action="store_true",
                      default=False, help="regenerate all files")
    opt, args = parser.parse_args()

    w = Webifier(src="src", out="out", styles="styles", layout="layout",
                 force=opt.force)
    w.webify()

if __name__ == "__main__":
    main()
