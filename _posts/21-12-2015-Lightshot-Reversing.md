---
layout: post
tagline: "Some simple behavior API analysis..."
category: reversing
tags : [api, reversing, php, json, request, response, emulator]
---
{% include JB/setup %}

Hello everyone,

No surprise it has been a **very long** time since I last wrote something here, I guess I don't have enough time or will to keep up with this blog. However, today I did something simple that I would like to share with you guys.

We all know screenshot tools like [Lightshot](https://app.prntscr.com), [PokIt](http://pokit.org) or [ShareX](https://getsharex.com). This blogpost will be about Lightshot in particular but these are just some alternatives to use.

I like Lightshot very much, it has a very simple interface with a text editor, some arrows and boxes and it is great for quick screencapping. However it has one downside: the uploader. The uploader uploads your image and then returns an URL in the [prntscr.com subdomain](http://prntscr.com/9gazao). This wouldn't be much of a problem, if the page wasn't ad infested and it is also difficult to get the direct link to the image (for example to link to in your blog).

Today I was bored so I decided to take a look at how their API works so we can change this behavior to show a direct link.

For tools I'll be using [Fiddler4](http://www.telerik.com/download/fiddler) and [XAMPP](https://www.apachefriends.org/index.html) (basically Apache, but XAMPP is just a nice wrapper around it for simplicity).

After you started Fiddler4, go in options and enable decryption of HTTPS traffic for non-browsers. This will notify you to install a new certificate in the root. This certificate is used for the man in the middle proxy so HTTPS traffic can be decrypted.

![fiddler options](/images/lightshot1.png)

Now simply capture something on your screen and hit the upload button in Lightshot. Fiddler should capture the traffic and you can stop the capture (F12).

The result looked something like this for me:

![fiddler capture](/images/lightshot2.png)

You can check out all the details of the traffic in the various tabs, but to summarize:

1. Lightshot uploads the image to [imgur](http://imgur.com) using the imgur API `imgur-apiv3.p.mashape.com`;
2. It sends some data to Google Analytics (not very interesting for us);
3. It sends a request to their own API `api.prntscr.com`.

Checking the request headers to their own API they look something like this (if you're logged in it will also contain a token for authorization, which I ommited for obvious reasons):

```
POST https://api.prntscr.com/v1/ HTTP/1.1
Accept: */*
Content-Type: application/x-www-form-urlencoded
Host: api.prntscr.com
Content-Length: 261
Cache-Control: no-cache

{"jsonrpc":"2.0","method":"save","id":1,"params":{"img_url":"http:\/\/i.imgur.com\/q2clfFY.png","thumb_url":"http:\/\/i.imgur.com\/q2clfFYs.png","delete_hash":"3VYbjevxfJ0qIJw","app_id":"{F1F88C8C-9A9B-45E2-913F-489DF108D86F}","width":450,"height":354,"dpr":1}}
```

The response is something like this:

```
HTTP/1.1 200 OK
Server: cloudflare-nginx
Date: Mon, 21 Dec 2015 17:51:55 GMT
Content-Type: application/json
Transfer-Encoding: chunked
Connection: keep-alive
Set-Cookie: __cfduid=d1a81c603fd50b8f9fbd992716bd5ce0f1450720314; expires=Tue, 20-Dec-16 17:51:54 GMT; path=/; domain=.prntscr.com; HttpOnly
X-Powered-By: PHP/5.5.9-1ubuntu4.14
CF-RAY: 2585700ef8880767-AMS

7b
{"jsonrpc":"2.0","id":1,"result":{"url":"http:\/\/prntscr.com\/9gvphh","info":"Anonymously uploaded image","success":true}}
0
```

As you can see, they send the imgur URL to the API and the API will add the image to the database and return their own custom URL. We just want the direct link to the image, so we are going to write a very simple emulator for this API that just returns the URL it was given.

The code is very simple, you can get it from [here](https://gist.github.com/mrexodia/c285581c2976480680ee) it should be really straightforward to understand, especially with the comments. Basically it does this:

1. Get the raw POST data (JSON encoded);
2. Decode the JSON to an associative array;
3. Construct a response associative array;
4. Encode the response in JSON;
5. Set the right header and echo the response text.

Their API uses chunked transfer encoding, but CURL eats a raw response just as well.

After putting this line in `C:\Windows\system32\drivers\etc\hosts` and putting the `index.php` file in `v1` everything appears to be working:

```
127.0.0.1 api.prntscr.com
```

![final result](/images/lightshot3.png)

That's all for now, I hope you enjoyed this post!

Mr. eXoDia