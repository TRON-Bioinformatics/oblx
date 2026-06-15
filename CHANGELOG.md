# Changelog

## [1.0.0](https://github.com/TRON-Bioinformatics/oblx/compare/v0.0.3...v1.0.0) (2026-06-15)

### ⚠ BREAKING CHANGES

- Add gnomAD genome resources
- **germline-variants:** Move gnomAD outputs to subdir

### Features

- Add bzipped and tabixed exome bed file
  ([0e0fca1](https://github.com/TRON-Bioinformatics/oblx/commit/0e0fca1ce4f8d8a80951bb2757f9cb1723559ccd))
- Add CDS bed file generation
  ([c311745](https://github.com/TRON-Bioinformatics/oblx/commit/c3117458e3a3cc7c26d80f61639b49e2ba14972c))
- Add gnomAD genome resources
  ([301db14](https://github.com/TRON-Bioinformatics/oblx/commit/301db14874b0c59abd8b663a4f7f9dfb6bb78d33))
- Add human gencode release 50 to gencode to ensembl mapping table
  ([9058516](https://github.com/TRON-Bioinformatics/oblx/commit/9058516c2d9bfae60f099beaa6074aaca6ad846f))
- Add Snakemake catalog infos
  ([e3252d1](https://github.com/TRON-Bioinformatics/oblx/commit/e3252d16f794522270cd3b6e407e4b19e52a1157))
- **bowtie2:** Add index rule, conda support (env + lock file)
  ([0c7a172](https://github.com/TRON-Bioinformatics/oblx/commit/0c7a17213664ad4399a78f3529aff85c042fb1ac))
- **bwa:** add bwa-mem index workflow outputs
  ([e057f29](https://github.com/TRON-Bioinformatics/oblx/commit/e057f29c52139c8a8cba7d81cc8f3fe9fc6a52f8))
- **germline-variants:** Move gnomAD outputs to subdir
  ([b27884a](https://github.com/TRON-Bioinformatics/oblx/commit/b27884a4dbb175a6be79bbd415432aa03fef154e))
- **gnomad:** Ensure temp files are cleaned
  ([ed20fb7](https://github.com/TRON-Bioinformatics/oblx/commit/ed20fb74901c3c34e12f602cb1dfe215e6b8a9d4))
- **hisat2:** Add rule, conda (env+lock file), container
  ([1daadd6](https://github.com/TRON-Bioinformatics/oblx/commit/1daadd6813a0dd6f9179caa193c3fba5da430c12))
- Initial support for UniProt annotation
  ([dd61bba](https://github.com/TRON-Bioinformatics/oblx/commit/dd61bbaaabfe24ae52b6d6878a1d4852e9b97a64))
- Introduce container support
  ([b0378c0](https://github.com/TRON-Bioinformatics/oblx/commit/b0378c0d408d5f2700b31cb20d7983f4ba69492d))
- Make star genomeSAindexNbases config parameter
  ([6350f9d](https://github.com/TRON-Bioinformatics/oblx/commit/6350f9d57756d270e13b0fbfba10b58a243a0d8c))
- Pull uniprot resources
  ([158c129](https://github.com/TRON-Bioinformatics/oblx/commit/158c1291cd2b11d38deda670b6a8906ee35b9f95))
- **rule-envs:** Pin conda rule env specs
  ([fcd980b](https://github.com/TRON-Bioinformatics/oblx/commit/fcd980bfcc9f650de87388bf89750c7cd3edb1f7))
- **star:** Simplify memory spec for star_index
  ([01383e8](https://github.com/TRON-Bioinformatics/oblx/commit/01383e84c6d3708e900c6c448f8fc09efd257d0c))
- Support apptainer execution
  ([cf12e7a](https://github.com/TRON-Bioinformatics/oblx/commit/cf12e7abcffc3f35d76e4ac30196472272d77bb9))
- Update default to gencode release 49 for human
  ([7eaba2c](https://github.com/TRON-Bioinformatics/oblx/commit/7eaba2c9070b508f935d8bee79fadd67016ed100))
- Updated sarek config file
  ([f3512ff](https://github.com/TRON-Bioinformatics/oblx/commit/f3512ff024c647d205d2aead3fcf71028bd73768))
- **workflow:** Add missing log directives
  ([925e095](https://github.com/TRON-Bioinformatics/oblx/commit/925e095d9a33cff33c30a9a2d003a56428791c4d))

### Bug Fixes

- Add conda-forge to gffread rule env
  ([090a52c](https://github.com/TRON-Bioinformatics/oblx/commit/090a52c8d444024d68329ceb92f6b8041daa20bd))
- Add pinned OpenSSL
  ([4eae809](https://github.com/TRON-Bioinformatics/oblx/commit/4eae809f1e7cac8739e6fb186c3195110a406577))
- Adjust pull_resources rulescript paths
  ([29ca213](https://github.com/TRON-Bioinformatics/oblx/commit/29ca213cd60fd32df19dca7a8f2e757e3582dbc1))
- **bowtie2:** Fix prefix generation
  ([6fdf802](https://github.com/TRON-Bioinformatics/oblx/commit/6fdf80296a1eb59cdd45b96a9eb63b76f1bead78))
- Correct sarek config paths
  ([cc2a289](https://github.com/TRON-Bioinformatics/oblx/commit/cc2a28995cd9cc013662dd8a8f8ed9092696738f))
- Correct STAR resource requirements for container usage
  ([d3aeb2f](https://github.com/TRON-Bioinformatics/oblx/commit/d3aeb2f180c1846644eb80f7ceb9da765b8b8963))
- Define salmon version in conda env
  ([52156be](https://github.com/TRON-Bioinformatics/oblx/commit/52156beb600e1a287f81a1f4402c56291baf1199))
- **docs:** address review_export.md findings
  ([293bfeb](https://github.com/TRON-Bioinformatics/oblx/commit/293bfebd7662d60b92e1d69b18b2283ebaf52b6a))
- Ensure genome build error message works
  ([93d3310](https://github.com/TRON-Bioinformatics/oblx/commit/93d3310274172bb7c0bd23842f3b8fbe7ace0642))
- **exome-bed:** Allow empty bed
  ([45845ee](https://github.com/TRON-Bioinformatics/oblx/commit/45845ee07ce91971bd8d728ac6f0a13658cc545a))
- **hisat2:** Skip index building for mouse
  ([19d6701](https://github.com/TRON-Bioinformatics/oblx/commit/19d6701d793cff440877b3c2d520242701498d62))
- Increase memory for kallisto
  ([#41](https://github.com/TRON-Bioinformatics/oblx/issues/41))
  ([fae4521](https://github.com/TRON-Bioinformatics/oblx/commit/fae4521710f6335a15972634f84654c4f0d9c531))
- Move kallisto index resources to default profil
  ([bf194ef](https://github.com/TRON-Bioinformatics/oblx/commit/bf194ef733777c0fe12b30342632765af7781de1))
- Path to envs
  ([fae3870](https://github.com/TRON-Bioinformatics/oblx/commit/fae3870447349dc3d2e5d29b9b32a033ca2f022b))
- Pin http storage plugin
  ([44d93e1](https://github.com/TRON-Bioinformatics/oblx/commit/44d93e134b31c629ebd6622c5e464b40b6ac186e))
- Repair the Snakemake version badge
  ([dae9862](https://github.com/TRON-Bioinformatics/oblx/commit/dae986207f0fc2b50afd5607c3a47c8482c62972))
- **salmon-decoy:** Add missing shebang
  ([dcde1b3](https://github.com/TRON-Bioinformatics/oblx/commit/dcde1b3a3ef34cbb76adbfdebaeb81050a8aaa6c))
- **snpeff:** Remove duplicate verbose option
  ([c31a522](https://github.com/TRON-Bioinformatics/oblx/commit/c31a522347d06e9991833745c1bd7fbf57586b5a))
- Update gatk URL
  ([f953361](https://github.com/TRON-Bioinformatics/oblx/commit/f953361a4c28e81e10a3a867be418a48696a847c))
- Use OpenSSL 3.4.2
  ([fd1f363](https://github.com/TRON-Bioinformatics/oblx/commit/fd1f363de8aeea8b57db193a78d8e3362ccdd2ac))

### Dependencies

- Constrain mkdocs \<2.0
  ([decf907](https://github.com/TRON-Bioinformatics/oblx/commit/decf907f8c28f535a1277daa41b4efd45302af61))
- **kb-tools:** Get kb-python via conda
  ([43bd5ab](https://github.com/TRON-Bioinformatics/oblx/commit/43bd5ab9472c6fa7ca24a2fec2c2bf1f6d6273ee))
- **r-env:** Fix conda env
  ([1190c69](https://github.com/TRON-Bioinformatics/oblx/commit/1190c69fb22981ed5d3413b105ae6f64a49bbf78))
- Remove unused packages
  ([c73e75a](https://github.com/TRON-Bioinformatics/oblx/commit/c73e75a8ef24e8d7d30cc0fd3ee449b7cd85f968))
- **workflow:** Update to 9.20.0
  ([da77026](https://github.com/TRON-Bioinformatics/oblx/commit/da77026c2d72972c231c4834e10e5524de83c76e))

### Documentation

- Add chrom-filter description in schema
  ([7dddf12](https://github.com/TRON-Bioinformatics/oblx/commit/7dddf12516a4e9434d7f71759f057d876b697f90))
- Add citations
  ([098da18](https://github.com/TRON-Bioinformatics/oblx/commit/098da18267aed122f1cade8a445ca4bcd3ed9d51))
- Add documentation for used resources
  ([f1b3905](https://github.com/TRON-Bioinformatics/oblx/commit/f1b3905072882440eff8be26af1645c076a09242))
- Add instructions how to run bioinfo pipelines with oblx library
  ([d10c43c](https://github.com/TRON-Bioinformatics/oblx/commit/d10c43c1d7ff2a9ebf9a89fcbaf6f684e04efa42))
- Add license note and citations
  ([ce566a2](https://github.com/TRON-Bioinformatics/oblx/commit/ce566a258d3c29c9084c4012df9043f270147180))
- Add logo
  ([94d090e](https://github.com/TRON-Bioinformatics/oblx/commit/94d090ecc794a98be3215b099c0c0d05ab83c577))
- Add note on viral sequences
  ([954baf0](https://github.com/TRON-Bioinformatics/oblx/commit/954baf06e9b17139182167a49648ddd548cc3f2d))
- Add origin of vertebrate_mitochondrial.txt
  ([37f88a4](https://github.com/TRON-Bioinformatics/oblx/commit/37f88a4ceb6c136efa1ae96d9f9b5286684ac941))
- Add output files and supported tools
  ([fbff92c](https://github.com/TRON-Bioinformatics/oblx/commit/fbff92c20d587ab123339d3f65f0cdb02c08d2f0))
- Add pandas as required for install description
  ([fcfdd02](https://github.com/TRON-Bioinformatics/oblx/commit/fcfdd024bde67bac670edf49e163e123765d9558))
- Add pixi task descriptions
  ([62562d2](https://github.com/TRON-Bioinformatics/oblx/commit/62562d2ee3feacf4a23fbabdd619431b2d7ac70c))
- Add table reader plugin to mkdocs.yaml
  ([ae92c04](https://github.com/TRON-Bioinformatics/oblx/commit/ae92c04d3cb76ee37cf939a298188d0cf7181835))
- Add tbi files to supported tools table and fix exome bed for haplotype caller
  and mutect2
  ([d60e9f1](https://github.com/TRON-Bioinformatics/oblx/commit/d60e9f1e3eda3e45b5bcf8d0875a1acda72ea59f))
- Add workflow graph
  ([d4263e9](https://github.com/TRON-Bioinformatics/oblx/commit/d4263e9df0affdaa51c8f8f3b64597f45391da05))
- Change docs colors and add github
  ([4ee0068](https://github.com/TRON-Bioinformatics/oblx/commit/4ee006862824afd55eb2239267f4b7710ce258b9))
- **config:** Add advice to just use defaults
  ([245525a](https://github.com/TRON-Bioinformatics/oblx/commit/245525add3ed6746e8ac5d1a832329d3ad358682))
- **config:** Mention container config
  ([f0778ac](https://github.com/TRON-Bioinformatics/oblx/commit/f0778acf68e1379e935692599beed4ecf89ae84e))
- **config:** Mention the schema
  ([a17a72f](https://github.com/TRON-Bioinformatics/oblx/commit/a17a72f3508968592a609e3e3e015b346bcddd75))
- **config:** Replace README link with stub doc
  ([43e64ee](https://github.com/TRON-Bioinformatics/oblx/commit/43e64ee7278e688e544869b5ca430290da88fff1))
- create CITATION.cff
  ([744c5d6](https://github.com/TRON-Bioinformatics/oblx/commit/744c5d6882583aab613115a03ddcceaa571baec0))
- **dev-guide:** Let people know about release-please
  ([8da40a1](https://github.com/TRON-Bioinformatics/oblx/commit/8da40a15da6341b22c574baa3af2adf747a0f7a8))
- Fix build indices output directory structure
  ([d9b28f6](https://github.com/TRON-Bioinformatics/oblx/commit/d9b28f677f4f55793904bbe660b9bc9f7c3b4147))
- **index:** Center-align logo
  ([241fa2c](https://github.com/TRON-Bioinformatics/oblx/commit/241fa2cb09c40d3a4a4bff59ec5db80c29fc3d69))
- **index:** Center-align workflow graph
  ([dbd5d32](https://github.com/TRON-Bioinformatics/oblx/commit/dbd5d328a843305e0f91bcd5a58d5a11c9ba31c5))
- **index:** Copy workflow graph alt text
  ([af42b36](https://github.com/TRON-Bioinformatics/oblx/commit/af42b3697397ef065f63ea3fdd1bc62e9183aa38))
- **index:** Fix Snakemake badge
  ([866ec7a](https://github.com/TRON-Bioinformatics/oblx/commit/866ec7ac200f16548ea5027759f266927a57a750))
- **index:** Set logo to 25% width
  ([79613b3](https://github.com/TRON-Bioinformatics/oblx/commit/79613b326814a754402797a67200da0801496082))
- Link config docs into config dir
  ([989e4ff](https://github.com/TRON-Bioinformatics/oblx/commit/989e4ff5f19fb91e4d2034aa109a25802dbaba0d))
- **logo:** Add light-gray contour to logo
  ([647019c](https://github.com/TRON-Bioinformatics/oblx/commit/647019c59191bd17c828969d9fb34248583effa4))
- **logo:** Remove transparent border
  ([f28d3f2](https://github.com/TRON-Bioinformatics/oblx/commit/f28d3f21e6e034a72d7e47aa9e8f9fe4373c1026))
- Move contribution in README and add developer guide
  ([057fb37](https://github.com/TRON-Bioinformatics/oblx/commit/057fb37f7558f8336c20141eda72f8138e3ba2d9))
- **README:** Add alt text for workflow graph
  ([51dc5d7](https://github.com/TRON-Bioinformatics/oblx/commit/51dc5d726ee7dd37850022fe9f42dc2623c93826))
- **README:** Annotate code block
  ([5d882c2](https://github.com/TRON-Bioinformatics/oblx/commit/5d882c2c9a7ab11c354f15a5f5f4fac3131a5041))
- **README:** Center align workflow graph
  ([e85ee46](https://github.com/TRON-Bioinformatics/oblx/commit/e85ee46f1b52fe6f439922c02b5ee29f5b32bd06))
- **scripts:** Remove author and version infos
  ([8b334ce](https://github.com/TRON-Bioinformatics/oblx/commit/8b334cedee6567a540b6ba65bbd813e98bd0e4bb))
- Setup documentation generation in CI
  ([fd408d8](https://github.com/TRON-Bioinformatics/oblx/commit/fd408d84bbde4e7a85546fe84131ae8446d560dd))
- Update note on pre-built indices
  ([29ee011](https://github.com/TRON-Bioinformatics/oblx/commit/29ee0113421baac82d319994edf628017aae419e))
