import QtQuick 1.0

XmlListModel {
    id: xmlModel

    property int totalResults
    property string namespaces : "<?xml version='1.0' encoding='UTF-8'?> <feed xmlns='http://www.w3.org/2005/Atom' xmlns:openSearch='http://a9.com/-/spec/opensearch/1.1/' xmlns:gd='http://schemas.google.com/g/2005' xmlns:yt='http://gdata.youtube.com/schemas/2007' gd:etag='W/&quot;A0AEQXc4eSp7ImA9WhZXFk8.&quot;'>"

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
    namespaceDeclarations: "declare default element namespace 'http://www.w3.org/2005/Atom'; declare namespace media = 'http://search.yahoo.com/mrss/'; declare namespace openSearch = 'http://a9.com/-/spec/opensearch/1.1/'; declare namespace gd = 'http://schemas.google.com/g/2005'; declare namespace yt = 'http://gdata.youtube.com/schemas/2007';"

    XmlRole { name: "title"; query: "yt:username/string()" }
    XmlRole { name: "subscriptionId"; query: "id/string()"; isKey: true }
}
