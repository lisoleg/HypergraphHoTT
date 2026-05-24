(lang dune 3.8)
(using coq 0.8)

(name HypergraphHoTT)

(generate_opam_files true)

(source
 (github HypergraphHoTT/HypergraphHoTT))

(authors "HypergraphHoTT Project")

(maintainers "HypergraphHoTT Project")

(license MIT)

(package
 (name coq-hypergraphhott)
 (depends
  (coq (>= 8.18))
  (coq-hott (>= 8.18))
  (coq-mathcomp-ssreflect (>= 2.0))
  (coq-mathcomp-finmap (>= 2.0))
  (coq-mathcomp-algebra (>= 2.0))))

; Coq-HoTT 与 MathComp 需在同一 Coq 版本下工作
; 编译选项 -noinit -indices-matter 在 _CoqProject 中声明
