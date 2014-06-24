Lufthouse README

Copyright (c) 2014 Lufthouse. All rights reserved.



**Concerning the JSON**

We start by defining the relation between the JSON, the customer, and a tour. The JSON contains all customer
records and the tours that belong to each customer. In that, we state that the JSON has many customers, and
a customer has many tours.

The structure of the JSON resembles the following:

    {
        "Customer1": {
            "TourNameA" : {
                "beacon1": ["content", "contentType", "audio"],
                "beacon2": ["content", "contentType", "audio"],
                "beacon3": ["content", "contentType", "audio"],
                "beacon4": ["content", "contentType", "audio"]
            },
            "TourNameB" : {
                "beacon1": ["content", "contentType", "audio"],
                "beacon2": ["content", "contentType", "audio"],
                "beacon3": ["content", "contentType", "audio"],
                "beacon4": ["content", "contentType", "audio"]
            },
            "TourNameC" : {
                "beacon1": ["content", "contentType", "audio"],
                "beacon2": ["content", "contentType", "audio"],
                "beacon3": ["content", "contentType", "audio"],
                "beacon4": ["content", "contentType", "audio"]
            }
        },
        "Customer2": {
            "TourNameA" : {
                "beacon1": ["content", "contentType", "audio"],
                "beacon2": ["content", "contentType", "audio"],
                "beacon3": ["content", "contentType", "audio"],
                "beacon4": ["content", "contentType", "audio"]
            },
            "TourNameB" : {
                "beacon1": ["content", "contentType", "audio"],
                "beacon2": ["content", "contentType", "audio"],
                "beacon3": ["content", "contentType", "audio"],
                "beacon4": ["content", "contentType", "audio"]
            },
            "TourNameC" : {
                "beacon1": ["content", "contentType", "audio"],
                "beacon2": ["content", "contentType", "audio"],
                "beacon3": ["content", "contentType", "audio"],
                "beacon4": ["content", "contentType", "audio"]
            }
        }
    }


All entries must have a comma after them unless they are the last entry in a tour, the last tour in a customer, or the last
customer in the JSON.

*Concerning Audio*

When including audio, place the name of the file with extension into the audio part of the entry. If you
wish to not include audio, put "nil" in the place instead.

Examples:

        "beacon1": ["content", "contentType", "mySong.mp3"],
        "beacon2": ["content", "contentType", "nil"]

*Concerning Content and Content Types*

The following content types are availble in the app:

"web" - This is a basic webpage. Using the URL to said webpage, add the following to the JSON:

    "beacon-id" : ["http://www.yourURLHere.com", "web", "yourAudioFile.mp3"]
    
"image" - This is a local image. Include the name of the file with extension, as such:

    "beacon-id" : ["yourImage.png", "image", "yourAudioFile.mp3"]
    
"web-video" - This is an online video for YouTube. It is displayed in an embedded video player. It cannot
    autoplay, and takes the id section from the YouTube URL (e.x. "12345Z" from www.youtube.com/watch?v=12345Z):
    
    "beacon-id" : ["YOURIDHERE", "web-video", "nil"]
    
"local-video" - This is a local video that will autoplay in the WebView. Insert the filename with extension like so:

    "beacon-id" : ["yourMovie.mp4", "local-video", "nil"]

