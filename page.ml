open Tyxml.Html

let header t =
  head
    (title (pcdata t))
    ([meta ~a:[a_charset "UTF-8"] ();
      style [ pcdata
    {___|body {
           font-family: monospace;
           color: #333;
         }
         .content {
           margin: 10% 0 10% 15%;
           width: 45%;
         }
         a, a:visited {
           color: #333;
           text-decoration: none;
           font-weight: bold;
         }|___} ]
        ])

let content =
  Omd.to_html (Omd.of_string
{___|# 3rd MirageOS hack retreat

We invite you to participate in the third [MirageOS](https://mirage.io)
hack retreat!  We will celebrate the Mirage3 release.
The goal is to sync various MirageOS subprojects, start new ones,
and fix some bugs.

* *When?* 1st (arrival) - 8th (departure) March 2017
* *Where?* Marrakech, Morocco at [Priscilla, Queen of the Medina](http://queenofthemedina.com/en/index.html).
* *How much?* 275 EUR<sup>&#9733;</sup> (accommodation and food (full board)).
* *How do I register?* Register by sending a mail to <marrakech2017@nqsb.io> **by January 15th, 2017** including:
   * Possibly what you are interested to work on (in case you already know);
   * Dietary restrictions; and
   * Day of arrival and departure (in case you already know, otherwise tell us once you know).
* *Who should participate?* Everybody interested in MirageOS.
* *How big?* We have only limited space (up to 35 people).

<sup>&#9733;</sup>: If you cannot afford this, please contact us directly (at <marrakech2017@nqsb.io>).

<br/>

More information
* Once you've signed up, we will subscribe you to a mailing list with all participants.
* You can work on anything but if you need inspiration, browse the [projects](http://canopy.mirage.io/tags/help%20needed) which need help.
* The nearest airport is [Marrakesh Menara Airport (RAK)](https://en.wikipedia.org/wiki/Marrakesh_Menara_Airport).  There is also Marrakesh Railway Station (train service from and to Tangier, reachable from Spain by ferry).
* From airport or railway station, take a cab to **Jemaa el-Fnaa** (city centre).
* Follow the map below, the destination address is **27 Derb el Ferrane Azbezt**.
* A [video](https://www.youtube.com/watch?v=zgzwmyxlKBE) contains detailed descriptions.
* We are also happy to pick you up at Jemaa el-Fnaa (phone number will be provided once you registered).


![Map](https://raw.githubusercontent.com/mirage/marrakech2017/master/data/map.jpg)
|___})

let rendered =
  let buf = Buffer.create 500 in
  let fmt = Format.formatter_of_buffer buf in
  pp () fmt @@
  html
    (header "3rd MirageOS hack retreat")
    (body [ Unsafe.data content ]) ;
  Cstruct.of_string @@ Buffer.contents buf
