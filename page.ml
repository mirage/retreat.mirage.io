open Tyxml.Html

let header t =
  head
    (title (pcdata t))
    ([meta ~a:[a_charset "UTF-8"] ();
      style [ pcdata
    {___|body {
           font-family: monospace;
           color: #333;
           margin: 2% 0 10% 15%;
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
{___|# 5th MirageOS hack retreat

We invite you to participate in the fifth [MirageOS](https://mirage.io)
hack retreat!
The goal is to sync various MirageOS subprojects, start new ones,
and fix bugs.

* *When?* 7th March (arrival) - 18th March (departure) 2018
* *Where?* Marrakech, Morocco at [Priscilla, Queen of the Medina](http://queenofthemedina.com/en/index.html).
* *How much?* 450 EUR<sup>&#9733;</sup> (accommodation and food (full board)).
* *How do I register?* Register by sending a mail to <retreat2018@nqsb.io> **by February 5th, 2018** including:
   * OCaml and MirageOS experience;
   * Project(s) you're interested to work on; and
   * Dietary restrictions
* *Who should participate?* Everybody interested in advancing MirageOS.
* *How big?* We have only limited space (30 people).  Selection will be done by various diversity criteria.

<sup>&#9733;</sup>: If you cannot afford this, please contact us directly (at <retreat2018@nqsb.io>).

<br/>

More information
* Once you've signed up, we will subscribe you to a mailing list with all participants.
* You can work on anything but if you need inspiration, browse the [projects](http://canopy.mirage.io/tags/help%20needed) which need help.
* The nearest airport is [Marrakesh Menara Airport (RAK)](https://en.wikipedia.org/wiki/Marrakesh_Menara_Airport).  There is also Marrakesh Railway Station (train service from and to Tangier, reachable from Spain by ferry).
* From airport or railway station, take a cab to **Jemaa el-Fnaa** (city centre).
* Follow the [map](https://raw.githubusercontent.com/mirage/marrakech2017/master/data/map.jpg), the address is **27 Derb el Ferrane Azbezt**.
* A [video](https://www.youtube.com/watch?v=zgzwmyxlKBE) contains detailed descriptions.
* We are also happy to pick you up at Jemaa el-Fnaa (phone number will be provided once you registered).

Previous retreats:
* 4th November 29th - December 6th 2017 in Marrakesh [report](https://mirage.io/blog/2017-winter-hackathon-roundup)
* 3rd March 1st - 8th 2017 in Marrakesh [report](https://mirage.io/blog/2017-march-hackathon-roundup)
* 2nd 13th July 2016 at Darwin College in Cambridge [report](https://mirage.io/blog/2016-summer-hackathon-roundup)
* 1st March 11th - 16th 2016 in Marrakesh [report](https://mirage.io/blog/2016-spring-hackathon)
|___})

let rendered =
  let buf = Buffer.create 500 in
  let fmt = Format.formatter_of_buffer buf in
  pp () fmt @@
  html
    (header "MirageOS hack retreats")
    (body [ Unsafe.data content ]) ;
  Cstruct.of_string @@ Buffer.contents buf
