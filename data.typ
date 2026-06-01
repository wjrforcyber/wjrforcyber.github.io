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
      category: "course",
      links: (
        slides: "talks/lnn.pdf",
      )
    )
  ),
  ukf: (
    title: "Application and Implementation of Univariate Kalman Filter",
    talk: (
      where: "Lab M4 – Task 4.3, MICS6002K: Artificial Intelligence for Time-Series Analysis",
      date: datetime(day: 1, month: 5, year: 2026),
      category: "course",
      links: (
        slides: "talks/MICS6002K_UKF.pdf",
      )
    )
  ),
  logic-synthesis: (
    title: "Logic Synthesis in a Nutshell",
    talk: (
      where: "Microelectronics Thrust, Function Hub, HKUST(GZ)",
      date: datetime(day: 7, month: 5, year: 2025),
      category: "course",
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
      category: "thesis",
      links: (
        slides: "talks/plug-talk.pdf",
        paper: "pub/isih.pdf",
      )
    )
  ),
  bounded-dll: (
    title: "Bounded Dynamic Level Maintenance for Efficient Logic Optimization",
    coauthor: (
      "Junfeng Liu",
      "Qinghua Zhao",
      "Liwei Ni",
      "Jingren Wang",
      "Biwei Xie",
      "Xingquan Li",
      "Bei Yu",
      "Shuai Ma",
    ),
    paper: (
      journal: (
        published: "IEEE Transactions on Computers",
        year: "2026",
        links: (
          doi: "https://ieeexplore.ieee.org/abstract/document/11499441/",
          arxiv: "https://arxiv.org/abs/2512.12554",
        )
      )
    ),
  ),
  inv-redist: (
    title: "Inverter Redistribution through Self-Dual and Self-Anti-Dual Function Transformation",
    coauthor: (
      "Jingren Wang",
      "Guangyu Hu",
      "Shiju Lin",
      "Hongce Zhang",
    ),
    paper: (
      conference: (
        published: "International Workshop on Logic & Synthesis (IWLS)",
        year: "2026",
        links: (
          arxiv: "https://arxiv.org/abs/2605.08743",
          slides: "talks/IWLS26.pdf"
        )
      )
    ),
  ),
)
