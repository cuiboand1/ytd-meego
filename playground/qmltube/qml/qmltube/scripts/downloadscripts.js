WorkerScript.onMessage = function(message) {
    console.log(message.model)
    if (message.action == 'setQuality') {
        message.model.currentDownload["quality"] = quality;
    }
    else if (message.action == 'setStatus') {
        message.model.currentDownload["status"] = status;
    }
    else if (message.action == 'setProgress') {
        message.model.currentDownload["bytesReceived"] = bytesReceived;
        message.model.currentDownload["totalBytes"] = bytesTotal;
        console.log(model.currentDownload.bytesReceived);
    }
    message.model.sync();
}

