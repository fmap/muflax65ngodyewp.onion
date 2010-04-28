#!/usr/bin/env python3
# Copyright muflax <mail@muflax.com>, 2010
# License: GNU GPL 3 <http://www.gnu.org/copyleft/gpl.html>

import datetime
import glob
import hashlib
import os
import os.path
import re
import subprocess

import PyRSS2Gen as RSS2
import clevercss
import yaml
try:
    from yaml import CLoader as Loader
except ImportError:
    from yaml import Loader
    
def _breadcrumbtagify(file, name=None, depth=0):
    """turn an address and name into a proper link"""
    if not name:
        name = file
    relpath = "../" * depth
    r = "<a href='{}{}' class='crumb'>{}</a>".format(relpath, file, name)
    return r

def make_breadcrumb(file, meta):
    """turn current path into breadcrumb navigation""" 
    crumbs = []
    depth = len(meta["cats"])
    for catfile, cat in meta["cats"]:
        crumbs.append(_breadcrumbtagify(catfile, cat, depth=depth))
        depth -= 1
    
    crumbs.append(_breadcrumbtagify(os.path.basename(file), "<>"))
    return " &#187; ".join(crumbs)

def templatify(file, meta, out):
    """templatify file using meta and save it at out"""
    print("\ttemplatifying {}...".format(file))
    dest = os.path.join(out, os.path.basename(file).replace(".pdc", ".html"))
    breadcrumb = make_breadcrumb(dest, meta)
    
    pandoc = ["pandoc",
              "--template", os.path.join("layout", meta["layout"]),
              "--css", os.path.join("style", meta["style"]),
              "--variable", "breadcrumb:{}".format(breadcrumb),
              "-o", dest,
              file
             ]
    subprocess.call(pandoc)
    print("\tsaving as {}...".format(dest))

def make_html_files(src, out, meta=None):
    """turn all *.pdc in src into html files in out"""
    
    # we'll have to manually walk this shit...
    # read the metadata and update the old one   
    meta = {} if meta == None else meta.copy() 
    print("reading metadata in {}...".format(src))
    meta_file = os.path.join(src, "meta.yaml")
    with open(meta_file, "r") as f:
        data = yaml.load(f, Loader=Loader)
        meta.update(data)

    # add breadcrumb information to metadata
    if "cats" in meta:
        crumb = (os.path.basename(out), meta["title"])
        meta["cats"].append(crumb)
    else: # root path, needs to be renamed
        crumb = ("", meta["title"])
        meta["cats"] = [crumb]
        
    # templatify all files here
    if not os.path.exists(out):
        os.mkdir(out)
    for file in glob.glob(src+"/*.pdc"):
        templatify(file, meta, out)

    # generate an index files
    #TODO
    
    # do the same for all subdirectories 
    for dir in [d for d in os.listdir(src) 
                if os.path.isdir(os.path.join(src, d))]:
        make_html_files(src=os.path.join(src, dir), 
                        out=os.path.join(out, dir),
                        meta=meta)

def make_css(src, out):
    if not os.path.exists(out):
        os.mkdir(out)
    for file in glob.glob(os.path.join(src, "*.clevercss")):
        print("cssifying {}...".format(file))
        with open(file, "r") as f:
            conv = clevercss.convert(f.read())
        dest = os.path.join(out, os.path.basename(file).replace(".clevercss",
                                                                ".css"))
        with open(dest, "w") as f:
            print("\tsaving as {}...".format(dest))
            f.write(conv)

def make_rss_feed(changelog):
    """generate an RSS feed out of the Changelog"""

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
                pubDate = datetime.datetime(
                    int(entry.group("y")),
                    int(entry.group("m")),
                    int(entry.group("d"))
                ),
                guid = RSS2.Guid(
                    hashlib.md5(entry.group("desc").encode("utf8")).hexdigest()
                )
            )
        )
    
    feed = RSS2.RSS2(
        title = "muflax.com",
        link = "http://www.muflax.com",
        description = "lies and wonderland",
        lastBuildDate = datetime.datetime.now(),
        items = items[:10]
    )

    with open("out/rss.xml", "w") as f:
        print("writing RSS feed...")
        feed.write_xml(f, encoding="utf8")

def tidy_up(dir):
    """clean up all the (ht|x)ml we generated earlier..."""

    for root, dirs, files in os.walk(dir):
        for f in files:
            if re.match(".*\.xml", f):
                subprocess.call(["tidy", "-i", "-xml", "-m", "-q", "-utf8",
                                 os.path.join(root, f)])
            elif re.match(".*\.html", f):
                subprocess.call(["tidy", "-i", "--tidy-mark", "f", "-m", "-q", "-utf8",
                                 os.path.join(root, f)])
    
def main():
    make_html_files("src", "out")
    make_css("styles", "out/styles")
    make_rss_feed("out/changelog.html")
    tidy_up("out")

if __name__ == "__main__":
    main()
