# MyMarketplace
Simple app to see items

Architecture and Sequence diagram:
<img width="583" height="663" alt="Architecture" src="https://github.com/user-attachments/assets/243190d9-1c67-4ac7-815f-64dd76a8144d" />


Scree recording:

https://github.com/user-attachments/assets/8afd1426-78e6-42fd-a84a-d4011c9d6f00


How to use it?

Set class property isMock to true to test offline mode and false if you want to test with online API in below JSON


class EnvironmentManager {
   static let shared = EnvironmentManager()
   var isMock = true
}

JSON format:
[
    {
        "name": "Fido 1",
        "favorite": false,
        "itemDescription": "Description for Fido item: 1",
        "imageUrl": "https://picsum.photos/id/1/200/300",
        "syncStatus": false,
        "localId": null
    },
    {
        "name": "Fido 2",
        "favorite": false,
        "itemDescription": "Description for Fido item: 2",
        "imageUrl": "https://picsum.photos/id/2/200/300",
        "syncStatus": false,
        "localId": null
    }
]

Note: In offline mode also, if internet is corrected api will sync data to server. otherwise it saved offline and sync to server when re-launch application.
