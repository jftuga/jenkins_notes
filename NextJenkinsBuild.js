// this is a JavaScript Bookmarklet
// create a new bookmark named NextJenkinsBuild and place on the bookmarks bar
// when you click this, it will add one to the current build (in the URL) and then redirect
// the browser to this new URL - which will be your next Jenkins build number
//
// add this as the URL contents:
javascript: (() => { s = document.URL.split("/"); p = s.length - 2; window.location.href = s.slice(0, p).join("/") + "/" + (Number(s[p]) + 1) + "/" + s.slice(p + 1).join("/"); })();
