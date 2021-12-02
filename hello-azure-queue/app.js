var run = true;

function sleep(ms) {
    return new Promise((resolve) => {
        setTimeout(resolve, ms);
    });
}

process.on('SIGTERM', function () {
    process.exit(0);
});

process.on('SIGINT', function () {
    process.exit(0);
});

(async () => {
    try {

        const { QueueClient, QueueServiceClient } = require("@azure/storage-queue");
        // Retrieve the connection from an environment
        // variable called AZURE_STORAGE_CONNECTION_STRING
        const connectionString = process.env.AZURE_STORAGE_CONNECTION_STRING;
        const queueName = process.env.AZURE_STORAGE_QUEUE_NAME

        // Instantiate a QueueServiceClient which will be used
        // to create a QueueClient and to list all the queues
        const queueServiceClient = QueueServiceClient.fromConnectionString(connectionString);

        // Get a QueueClient which will be used
        // to create and manipulate a queue
        const queueClient = queueServiceClient.getQueueClient(queueName);


        // Create the queue if it doesn't exist
        if (!(await queueClient.exists())) {
            console.log("Creating queue: ", queueName);
            await queueClient.create();
        }

        console.log("Reading Queue Messages");

        while (run) {
            // Get the next message in the queue
            receivedMessages = await queueClient.receiveMessages();
            var message = receivedMessages.receivedMessageItems[0];
            if (message) {
                console.log("Dequeuing message: ", message.messageText);

                await queueClient.deleteMessage(message.messageId, message.popReceipt);
            }
            await sleep(1000);
        }

    } catch (e) {
        console.error(e);
    }
})();