import QtQuick 1.0

XmlListModel {
    id: xmlModel

    property int totalResults
    property string namespaces : "<?xml version='1.0' encoding='UTF-8'?> <feed xmlns='http://www.w3.org/2005/Atom' xmlns:app='http://www.w3.org/2007/app' xmlns:media='http://search.yahoo.com/mrss/' xmlns:openSearch='http://a9.com/-/spec/opensearch/1.1/' xmlns:gd='http://schemas.google.com/g/2005' xmlns:gml='http://www.opengis.net/gml' xmlns:yt='http://gdata.youtube.com/schemas/2007' xmlns:georss='http://www.georss.org/georss' gd:etag='W/&quot;DUAFSHwzeSp7ImA9Wx9VEkw.&quot;'>"

    function setXml(xml) {
        var idPos = xml.indexOf("<id>");
        var pos1 = xml.indexOf("totalResults") + 13;
        var pos2 = xml.indexOf("</openSearch:totalResults>");
        totalResults = parseInt(xml.substring(pos1, pos2));
        xmlModel.xml = namespaces + xml.substring(idPos);
    }

    function appendXml(xml) {
        var pos1 = xml.indexOf("<entry");
        var feedTag = xmlModel.xml.lastIndexOf("</feed>");
        xmlModel.xml = xmlModel.xml.substring(0, feedTag) + xml.substring(pos1);
    }

    query: "/feed/entry"
    namespaceDeclarations: "declare default element namespace 'http://www.w3.org/2005/Atom'; declare namespace media = 'http://search.yahoo.com/mrss/'; declare namespace openSearch = 'http://a9.com/-/spec/opensearch/1.1/'; declare namespace gd = 'http://schemas.google.com/g/2005'; declare namespace yt = 'http://gdata.youtube.com/schemas/2007'; declare namespace georss = 'http://www.georss.org/georss'; declare namespace app = 'http://www.w3.org/2007/app';"

    XmlRole { name: "videoId"; query: "media:group/yt:videoid/string()" }
    XmlRole { name: "id"; query: "id/string()"; isKey: true }
    XmlRole { name: "playerUrl"; query: "media:group/media:player/@url/string()" }
    XmlRole { name: "subject"; query: "title/string()" }
    XmlRole { name: "message"; query: "summary/string()" }
    XmlRole { name: "messageDate"; query: "published/string()" }
    XmlRole { name: "title"; query: "media:group/media:title/string()" }
    XmlRole { name: "description"; query: "media:group/media:description/string()" }
    XmlRole { name: "author"; query: "author/name/string()" }
    XmlRole { name: "uploader"; query: "media:group/media:credit/string()" }
    XmlRole { name: "thumbnail"; query: "media:group/media:thumbnail[1]/@url/string()" }
    XmlRole { name: "largeThumbnail"; query: "media:group/media:thumbnail[2]/@url/string()" }
    XmlRole { name: "duration"; query: "media:group/yt:duration/@seconds/string()" }
    XmlRole { name: "uploadDate"; query: "media:group/yt:uploaded/string()" }
    XmlRole { name: "views"; query: "yt:statistics/@viewCount/string()" }
    XmlRole { name: "comments"; query: "gd:comments/gd:feedLink/@countHint/string()" }
    XmlRole { name: "likes"; query: "yt:rating/@numLikes/string()" }
    XmlRole { name: "dislikes"; query: "yt:rating/@numDislikes/string()" }
    XmlRole { name: "tags"; query: "media:group/media:keywords/string()" }
}

