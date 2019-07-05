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
{___|# 8th MirageOS hack retreat

We invite you to participate in the seventh [MirageOS](https://mirage.io)
hack retreat!
The goal is to sync various MirageOS subprojects, start new ones,
and fix bugs.

* *When?* September 23rd (arrival) - 29th (departure) 2019
* *Where?* Marrakech, Morocco at [Priscilla, Queen of the Medina](http://queenofthemedina.com/en/index.html).
* *How much?* 350 EUR<sup>&#9733;</sup>, accommodation and food (full board) included.
* *How do I register?* Register by sending a mail to <retreat2019@nqsb.io> **by August 15th, 2019** including:
   * How you became interested in MirageOS;
   * Previous experience with MirageOS and OCaml (no upfront experience required) ;
   * Project(s) you're interested to work on; and
   * Dietary restrictions
* *Who should participate?* Everybody interested in advancing MirageOS.
* *How big?* We have only limited space (30 people).  Selection will be done by various diversity criteria.
* *How should I behave while there?* Be kind and empathetic to others; do not harrass or threaten anyone. If you make others unsafe, you may be asked to leave.

<sup>&#9733;</sup>: If you cannot afford this, please contact us directly (at <retreat2018@nqsb.io>).

<br/>

More information
* Once you've signed up, you will subscribed to the participants mailing list.
* You can work on anything but if you need inspiration, browse the [projects](http://canopy.mirage.io/tags/help%20needed) which need help.
* The nearest airport is [Marrakesh Menara Airport (RAK)](https://en.wikipedia.org/wiki/Marrakesh_Menara_Airport).  There is also Marrakesh Railway Station (train service from and to Tangier, reachable from Spain by ferry).
* From airport or railway station, take a cab to **Jemaa el-Fnaa** (city centre).
* Follow the [map](https://raw.githubusercontent.com/mirage/marrakech2017/master/data/map.jpg), the address is **27 Derb el Ferrane Azbezt**.
* A [video](https://www.youtube.com/watch?v=zgzwmyxlKBE) contains detailed descriptions.
* We are also happy to pick you up at Jemaa el-Fnaa (phone number will be provided once you registered).

Previous retreats:
* 7th March 6th - 13th 2019 in Marrakesh, reports: [report](https://mirage.io/blog/2019-spring-retreat-roundup) [lynxis](https://lunarius.fe80.eu/blog/mirageos-2019.html) [gabriel](http://gallium.inria.fr/blog/marrakesh-retreat-03-2019/) [tarides](https://tarides.com/blog/2019-05-06-7th-mirageos-hack-retreat.html)
* 6th October 3rd - 10th 2018 in Marrakesh
* 5th March 7th - 18th 2018 in Marrakesh, reports: [linse](https://linse.me/2018/04/20/Visiting-the-camels.html), [peter](https://mirage.io/wiki/arm64)
* 4th November 29th - December 6th 2017 in Marrakesh, reports: [mirage](https://mirage.io/blog/2017-winter-hackathon-roundup)
* 3rd March 1st - 8th 2017 in Marrakesh, reports: [mirage](https://mirage.io/blog/2017-march-hackathon-roundup), [reynir](http://reyn.ir/posts/2017-03-20-11-27-Marrakech%202017.html), [olle](http://ollehost.dk/blog/2017/03/17/travel-report-mirageos-hack-retreat-in-marrakesh-2017/)
* 2nd 13th July 2016 at Darwin College in Cambridge, [report](https://mirage.io/blog/2016-summer-hackathon-roundup)
* 1st March 11th - 16th 2016 in Marrakesh, [report](https://mirage.io/blog/2016-spring-hackathon)
|___})

let rendered =
  let buf = Buffer.create 500 in
  let fmt = Format.formatter_of_buffer buf in
  pp () fmt @@
  html
    (header "MirageOS hack retreats")
    (body [ Unsafe.data content ]) ;
  Cstruct.of_string @@ Buffer.contents buf
