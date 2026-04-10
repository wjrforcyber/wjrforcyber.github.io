#let render-coauthors(coauthors) = {
  if coauthors.len() == 0 { return }
  [ with ]
  if coauthors.len() > 1 { coauthors.push("and " + coauthors.pop()) }
  if coauthors.len() <= 2 {
    coauthors.join(" ")
  } else {
    coauthors.join(", ")
  }
}

#let projects = (
  lnn: (
    title: "Logical Neural Networks",
    talk: (
      where: "MICS6001: Symbolic and Neurosymbolic Reasoning, HKUST(GZ)",
      date: datetime(day: 11, month: 10, year: 2025),
      links: (
        slides: "talks/lnn.pdf",
      )
    )
  ),
  logic-synthesis: (
    title: "Logic Synthesis in a Nutshell",
    talk: (
      where: "Microelectronics Thrust, Function Hub, HKUST(GZ)",
      date: datetime(day: 7, month: 5, year: 2025),
      links: (
        slides: "talks/logic-synthesis.pdf",
      )
    )
  ),
  plug-talk: (
    title: "Implementing System T in Haskell",
    talk: (
      where: "PLUG Talk, School of Computing Science, University of Glasgow",
      date: datetime(day: 3, month: 5, year: 2022),
      links: (
        slides: "talks/plug-talk.pdf",
        paper: "pub/isih.pdf",
      )
    )
  ),
  dontcare: (
    title: "Don't Care Cheatsheet",
    paper: (
      preprint: (
        links: (
          pdf: "pub/dontcare.pdf",
        )
      )
    ),
  ),
  permutation: (
    title: "Simple Illustration of Permutation Technique",
    paper: (
      preprint: (
        links: (
          pdf: "pub/permutation.pdf",
        )
      )
    ),
  ),
)
