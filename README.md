#  N'ber / N-ber

N'ber or N-ber is a Swift project, the project is similar to whatsapp or telegram app.

## Installation


## Notes

Save messages to Firebase, because a realm messages save and there is no error, even though visiually we couldn't identify it. But we are going to assume that the message is there (OutgoingMessage.swift -> sendMessage method). We will check it once we start reading from realm database. But now I want to save also our messages to the firebase.


We never know how many users you have and you don't want to create the same data a million times on your database.. So what we are going to do is to have one chatroom on the firebase with all the channel messages there and all the users are going to just access there, so each user will not have his own indiviual chats for himself. So we have all one source of truth, which is our chats there. We get them. We can save them locally, but not each user has his own seperate chat on the firebase because this will be much more efficient way of saving things in our database
