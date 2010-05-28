#!/usr/bin/env python3
# Copyright muflax <mail@muflax.com>, 2010
# License: GNU GPL 3 <http://www.gnu.org/copyleft/gpl.html>

import copy
import datetime as dt
import glob
import hashlib
import http.server
import optparse
import os
import os.path as op
import re
import shutil
import subprocess
import sys

import PyRSS2Gen as RSS2
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
        self.relist = re.compile("""
                                <li>
                                (?P<desc>.+?)
                                </li>
                                """, re.X|re.S)
        self.recopy = re.compile("\.(yaml|pdc|swp)$")
        self.redate = re.compile("<p>(?P<y>\d+) / (?P<m>\d+) / (?P<d>\d+):",
                                 re.X)

    def webify(self):
        """wrapper for the whole process"""
            
        self.make_html_files(self.src, self.out)
        self.make_rss_feed(op.join(self.out, "changelog.html"))
        self.copy_media_files(self.src, self.out)
        self.copy_media_files(self.styles, op.join(self.out, self.styles))

    def copy_media_files(self, src, out):
        """copy all the other files, like images"""
        # again, we manually walk this shit... *sigh*
        for f in [f for f in os.listdir(src)
                  if (op.isfile(op.join(src, f))
                      and not self.recopy.search(f))]:
            if not os.path.exists(out):
                os.mkdir(out)
            shutil.copy2(op.join(src, f), op.join(out, f))
            
        for dir in [d for d in os.listdir(src) 
                    if op.isdir(op.join(src, d))]:
            self.copy_media_files(src=op.join(src, dir), 
                                  out=op.join(out, dir))

    def _breadcrumbtagify(self, file, name=None):
        """turn an address and name into a proper link"""
        if not name:
            name = file
        
        r = "<a href='{}' class='crumb'>{}</a>".format(file, name)
        return r

    def make_breadcrumb(self, file, meta):
        """turn current path into breadcrumb navigation""" 
        crumbs = []
        mod = -1 if op.basename(file) == "index.html" else 0
        for i in range(len(meta["cats"]) + mod):
            catname = meta["cats"][i]["name"]
            catfile = op.join(*[crumb["file"] for crumb in meta["cats"][:i+1]])
            crumbs.append(self._breadcrumbtagify(catfile, catname))

        crumbs.append("")
        return " &#187; ".join(crumbs)

    def templatify(self, file, meta, out):
        """templatify file using meta and save it at out"""
        print("\ttemplatifying {}...".format(file))
        dest_file = op.basename(file).replace(".pdc", ".html") 
        dest = op.join(out, dest_file )
        breadcrumb = self.make_breadcrumb(dest, meta)
        
        pandoc = ["pandoc",
                  "--template", op.join(self.layout, meta["layout"]),
                  "--css", op.join("/", self.styles, meta["style"]),
                  "--variable", "breadcrumb:{}".format(breadcrumb),
                  "--variable", "filename:{}".format(dest_file),
                  "-o", dest,
                  file
                 ]
        subprocess.call(pandoc)
        print("\t\tsaving as {}...".format(dest))
        self.tidy_up_html(dest)
        stat = os.stat(file)
        os.utime(dest, (stat.st_mtime, stat.st_mtime))

    def _is_newer(self, old, new):
        """return if old is newer than new"""
        try:
            mnew, mold = os.stat(new).st_mtime, os.stat(old).st_mtime 
        except OSError:
            return True
        return mold - mnew >= 1

    def make_html_files(self, src, out, meta=None):
        """turn all *.pdc in src into html files in out"""
        
        # we'll have to manually walk this shit...
        # read the metadata and update the old one   
        meta = {} if meta == None else copy.deepcopy(meta) 
        print("reading metadata in {}...".format(src))
        meta_file = op.join(src, "meta.yaml")
        with open(meta_file, "r") as f:
            data = yaml.load(f, Loader=Loader)
            meta.update(data)

        # add breadcrumb information to metadata
        crumb = {"file": op.basename(out), "name": meta["title"]}
        if "cats" in meta:
            meta["cats"].append(crumb)
        else: # root path, needs to be renamed
            crumb["file"] = "/"
            meta["cats"] = [crumb]
            
        # templatify all files here
        if not op.exists(out):
            os.mkdir(out)
        for f in glob.glob(src+"/*.pdc"):
            dest_file = op.basename(f).replace(".pdc", ".html") 
            dest = op.join(out, dest_file )
            if self.force or self._is_newer(f, dest):
                self.templatify(f, meta, out)
        
        # do the same for all subdirectories 
        for dir in [d for d in os.listdir(src) 
                    if op.isdir(op.join(src, d))]:
            self.make_html_files(src=op.join(src, dir), 
                                 out=op.join(out, dir),
                                 meta=meta)

    def make_rss_feed(self, changelog):
        """generate an RSS feed out of the Changelog"""
            
        dest = op.join(self.out, "rss.xml")
        if not (self.force or self._is_newer(changelog, dest)):
            return

        with open(changelog, "r") as f:
            print("parsing {}...".format(changelog))
            txt = f.read()
            
        items = []
        for entry in self.relist.finditer(txt):
            date = self.redate.search(entry.group("desc"))
            items.append(
                RSS2.RSSItem(
                    title = "omg new stuff!!w!",
                    link = "http://www.muflax.com/changelog.html",
                    description = entry.group("desc"),
                    pubDate = dt.datetime(
                        int(date.group("y")),
                        int(date.group("m")),
                        int(date.group("d"))
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

        with open(dest, "w") as f:
            print("writing RSS feed...")
            feed.write_xml(f, encoding="utf8")
            self.tidy_up_xml(dest)

    def tidy_up_html(self, f):
        """clean up the html we generated earlier..."""
            
        print("cleaning up {}...".format(f))
        subprocess.call(["tidy", "--tidy-mark", "f", "-i", "-m", "-q",
                         "-utf8", f])
        # What? You got a problem with me using Perl inside Python
        # to avoid patching Haskell?
        # Anyway, removes the last newline inside code blocks.
        subprocess.call(["perl", "-i", "-p", "-e", 
                         "s,<br /></code>,</code>,g", f])

    def tidy_up_xml(self, f):
        """clean up all the xml we generated earlier..."""
        
        print("cleaning up {}...".format(f))
        subprocess.call(["tidy", "-xml", "-i", "-m", "-q", "-utf8", f])

    def start_server(self, dir=""):
        """start a webserver"""
        old = os.getcwd()
        os.chdir(dir)
        try:
            http.server.test(HandlerClass=http.server.SimpleHTTPRequestHandler)
        except KeyboardInterrupt:
            pass
        finally:
            os.chdir(old)

def main():
    parser = optparse.OptionParser()
    parser.add_option("-f", "--force", dest="force", action="store_true",
                      default=False, help="regenerate all files")
    parser.add_option("-s", "--server", dest="server", action="store_true",
                      default=False, help="start webserver afterwards")
    opt, args = parser.parse_args()
    sys.argv[1:] = []

    w = Webifier(src="src", out="out", styles="styles", layout="layout",
                 force=opt.force)
    w.webify()

    if opt.server:
        w.start_server("out")

if __name__ == "__main__":
    main()
