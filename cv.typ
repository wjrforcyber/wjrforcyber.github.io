#import "@preview/modern-cv:0.9.0": *

#import "./data.typ": *

#show: resume.with(
  author: (
    firstname: "",
    lastname: "Jingren Wang",
    email: "jingrenwangcyber@gmail.com",
    github: "wjrforcyber",
    phone: none,
    orcid: none,
    website: "wjrforcyber.github.io",
    positions: ( "Ph.D. Student", )
  ),
  font: "Source Sans 3",
  header-font: "Source Sans 3",
  profile-picture: none,
  paper-size: "a4",
  show-footer: false,
  use-smallcaps: false,
  description: "CV",
)

#show heading.where(level: 1): it => {
  v(0.3cm)
  it
}

= Experience

#resume-entry(
  title: "Ph.D. Student",
  location: "HKUST(GZ), Microelectronics Thrust",
  date: "Sep 2025 - Present",
  description: [Research on logic synthesis and EDA, supervised by Prof. Hongce Zhang and Prof. Shiju Lin.
    #v(-0.5cm)
  ]
)

#resume-entry(
  title: "Research Assistant",
  location: "HKUST(GZ), Microelectronics Thrust",
  date: "May 2025 - Aug 2025",
  description: "Research assistant in the Microelectronics Thrust, Function Hub."
)

#resume-entry(
  title: "Logic Synthesis Engineer",
  location: "Raina Technology, Hangzhou",
  date: "Fall 2022 - Mar 2025",
  description: "R&D department, working on logic synthesis tools and algorithms."
)

#resume-entry(
  title: "Research Assistant",
  location: "University of Glasgow, School of Computing Science",
  date: "Feb 2022 - Jul 2022",
  description: [Responsible for communication between VR device and ROS, controlling a UR3E robotic arm in virtual space with real-time synchronization.]
)

= Education

#resume-entry(
  title: "Ph.D. in Microelectronics",
  location: "HKUST(GZ)",
  date: "2025 - Present",
  description: "Co-supervised by Prof. Hongce Zhang and Prof. Shiju Lin. Research focus on logic synthesis."
)

#resume-entry(
  title: "M.S. in Computing Science",
  location: "University of Glasgow",
  date: "2022",
  description: "Supervised by Dr. Vikraman Choudhury."
)

#resume-entry(
  title: "B.S. in Cyber Engineering",
  location: "Xidian University",
  date: "2020",
)

= Talks

#let render-talk(data) = {
  let talk = data.talk
  if type(talk) == array { talk = talk.at(0) }
  resume-entry(
    title: data.title,
    location: talk.where,
    date: talk.date.year(),
  )
}

#render-talk(projects.lnn)
#render-talk(projects.logic-synthesis)
#render-talk(projects.plug-talk)

= Teaching

#resume-entry(
  title: [Lab Teaching Assistant],
  location: [HKUST(GZ)],
  date: "2025-2026",
  description: [UFUG 1601 - Introduction to Computer Science (Spring)]
)
