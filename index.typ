#import "./data.typ": *

#html.link(rel: "stylesheet", href: "css/style.css")
#html.link(rel: "stylesheet", href: "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css")

#html.elem("h1")[Jingren Wang #html.elem("span", attrs: (class: "cn-name"))[（王靖仁）]]

#html.img(src: "profileStyle.jpg", class: "photo", width: 200, title: "Jingren Wang")

I am a Ph.D. student in Microelectronics at the Hong Kong University of Science and Technology (Guangzhou), jointly advised by Professor #link("http://hongcezh.people.ust.hk")[Hongce Zhang] and Professor #link("https://shijulin.github.io")[Shiju Lin]. My research focuses on logic synthesis and other topics in EDA.

Prior to my doctoral studies, I worked as a Synthesis Engineer in the R&D department at Raina Technology in Hangzhou, China. I hold a Master's degree in Computing Science from the University of Glasgow, where I was supervised by Dr. #link("https://vikraman.org")[Vikraman Choudhury], and a Bachelor's degree in Cyber Engineering from Xidian University.

= Contact

#table(
  columns: (auto, 1fr, auto),
  [Email], [#table.cell(colspan: 2)[jwang929 AT connect DOT hkust-gz DOT edu DOT cn]],
  [Office Address], [
    118, W4, 5th Floor\
    Microelectronics Thrust,\
    Function Hub, HKUST(GZ)\
    Guangzhou, Guangdong\
    China
  ], [#html.elem("div", attrs: (style: "width:200px;height:110px;overflow:hidden;border-radius:6px;border:1px solid #6272A4;"))[#html.elem("iframe", attrs: (
    width: "200",
    height: "200",
    frameborder: "0",
    scrolling: "no",
    src: "https://www.openstreetmap.org/export/embed.html?bbox=113.46166849136353%2C22.88364803405261%2C113.4948205947876%2C22.89654661304645&amp;layer=mapnik&amp;locale=en",
    style: "margin-top:-5px;",
  ))[]]],
  [GitHub], [#table.cell(colspan: 2)[#link("https://github.com/wjrforcyber")[#html.elem("i", attrs: (class: "fa-brands fa-github"))[] wjrforcyber]]],
  [Mastodon], [#table.cell(colspan: 2)[#link("https://mathstodon.xyz/@jingrenwang")[#html.elem("i", attrs: (class: "fa-brands fa-mastodon"))[] \@jingrenwang\@mathstodon.xyz]]],
)

= About Me

I am interested in logic synthesis, Boolean algebra, and electronic design automation (EDA). My current work explores technology-independent optimization techniques for combinational logic circuits, with an emphasis on intermediate representations and the structural properties that enable efficient synthesis.

= Talks

#let render-links(dict) = {
  if dict.len() == 0 { return }
  [(]
  dict.pairs().map(v => {
    let (key, value) = v;
    link(value, key)
  }).join(", ")
  [)]
}

#let all-talks = projects.values().map(v => {
  let t = v.at("talk", default: ());
  if type(t) != array { t = (t,) }
  t.map(x => (name: v.title, ..x))
}).flatten().sorted(key: x => x.date).rev()

#html.elem("h3")[Course Talks]

#for t in all-talks.filter(x => x.at("category", default: "") == "course") [
  - #t.date.display("[month repr:long] [year]"): #t.name, #t.where #render-links(t.links)
]

#html.elem("h3")[Thesis Talks]

#for t in all-talks.filter(x => x.at("category", default: "") == "thesis") [
  - #t.date.display("[month repr:long] [year]"): #t.name, #t.where #render-links(t.links)
]

= Publications

#let pubs = projects.pairs().filter(v => v.at(1).at("paper", default: (:)).len() != 0).sorted(key: v => {
  let p = v.at(1).at("paper")
  let y = p.at("conference", default: p.at("journal", default: p.at("preprint", default: (:)))).at("year", default: "0")
  int(y)
}).rev()

#for (idx, (key, data)) in pubs.enumerate() {
  let name = data.at("title")
  let paper = data.at("paper", default: (:))
  let coauthors = data.at("coauthor", default: ()).map(a => {
    if a == "Jingren Wang" { [*#a*] } else { a }
  })
  if paper.len() != 0 [
    #html.elem("div")[#html.elem("span", attrs: (style: "margin-right:8px;color:#6272A4;"))[#{idx + 1}.] #name #render-coauthors(coauthors)
    #if "preprint" in paper {
        [ ]
        render-links(paper.preprint.links)
      }
      #if "journal" in paper {
        [, ]
        paper.journal.published
        [ ]
        paper.journal.year
        [ ]
        render-links(paper.journal.links)
      }
      #if "conference" in paper {
        [, ]
        paper.conference.published
        [ ]
        paper.conference.year
        [ ]
        render-links(paper.conference.links)
      }
    ]
  ]
}

= Teaching

- TA for "MICS 6001X - Symbolic and Neurosymbolic Reasoning" (2026-2027 Fall), HKUST(GZ)
- Lab TA for "UFUG 1601 - Introduction to Computer Science" (2025-2026 Spring), HKUST(GZ)

= Posts

#let posts = (
  (
    title: [Don't Care Cheatsheet for Easy Comprehension],
    link: "pub/dontcare.pdf",
    date: datetime(day: 14, month: 1, year: 2025)
  ),
  (
    title: [Simple Illustration of Permutation Technique],
    link: "pub/permutation.pdf",
    date: datetime(day: 11, month: 2, year: 2025)
  ),
).sorted(key: x => x.date).rev()

#for post in posts {
  [- #link(post.link, post.title) - #post.date.display()]
}

#html.elem("div", attrs: (class: "footer-section"))[
  #html.elem("div", attrs: (class: "footer-line"))[]
  #html.elem("div", attrs: (class: "footer-credit"))[Template credit: #link("https://alexarice.github.io")[Alex Rice]]
  #html.elem("br")
]
