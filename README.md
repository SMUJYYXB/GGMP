# GGMP
Population-based survey linking gut microbiome to economic development and metabolic syndrome
################################################################################################################
## Introduction
Analysis pipeline for: Population-based survey linking gut microbiome to economic development and metabolic syndrome

### Copyright
  Copyright:     Prof. Hong-Wei Zhou
Institution:     State Key Laboratory of Organ Failure Research, Division of Laboratory Medicine,
                   Zhujiang Hospital, Southern Medical University, Guangzhou, China, 510282
      Email:     biodegradation@gmail.com
### Author
     Author:     Hui-Min Zheng, Pan Li, Xian Wang and Yan He 
Last update:     2017-04-18
      Email:     328093402@qq.com
### Index
1 Environment
    1.1 System
        1.1.1 System Platform
        1.1.2 Hardware
    1.2 R
        1.2.1 R version
        1.2.2 R libraries
    1.3 MaAsLin
    1.4 Qiime
        1.4.1 Qiime version
        1.4.2 System information
        1.4.3 QIIME default reference information
        1.4.4 QIIME config values
    1.5 BBMap
2 Demo data
    2.1 original sequences
    2.2 metadata
3 Scripts
    3.1 Perl Scripts
    3.2 R Scripts
4 Supplementary files
    4.1 metadata_category.txt
    4.2 taxa.list
5 Direction for use
########################################################
1 Environment
--------------------------------------------------------
#########################################################
1.1 System
-------------------------------------------------------
1.1.1 System Platform
-------------------------------------------------------
    Platform:      Linux2 
     Version:      Linux version 2.6.32-573.8.1.el6.x86_64 (mockbuild@c6b8.bsys.dev.centos.org) (gcc version 4.4.7 20120313 (Red Hat 4.4.7-16)(GCC))
          OS:      CentOS release 6.7 (Final)
--------------------------------------------------------
1.1.2 Hardware
--------------------------------------------------------
         Cpu(s):      >10
         thread:      >10
            RAM:      >10G
      Hard disk:      >2T
--------------------------------------------------------

1.3 R
-------------------------------------------------------
1.3.1 R version
-------------------------------------------------------
        Version:      R version 3.2.5(Linux)(2016-04-14)(www.r-project.org)
      Copyright:      (C) 2016 The R Foundation for Statistical Computing
--------------------------------------------------------
1.3.2 R libraries
-------------------------------------------------------
      ggplot2
      psych
      reshape
      agricolae
      gam
      gamlss
      gbm
      glmnet
      inlinedocs
      logging
      MASS
      nlme (version 3.1-127)
      optparse
      outliers
      penalized
      pscl
      robustbase
--------------------------------------------------------
1.3 MaAsLin
-------------------------------------------------------
    (https://bitbucket.org/biobakery/maaslin/)
    Package: Maaslin
    Type: Package
    Title: Maaslin
    Version: 0.0.3
    Imports: agricolae, gam, gamlss, gbm, glmnet, inlinedocs, logging,
        MASS, nlme, optparse, outliers, penalized, pscl, robustbase
    Date: 2014-12-04
    Author: Timothy Tickle<ttickle@hsph.harvard.edu>, Curtis Huttenhower <chuttenh@hsph.harvard.edu>
    Maintainer: Timothy Tickle <ttickle@hsph.harvard.edu>,Ayshwarya
        Subramanian<subraman@broadinstitute.org>,Lauren
        McIver<lauren.j.mciver@gmail.com>,George
        Weingart<george.weingart@gmail.com>
    Description: MaAsLin is a multivariate statistical framework that finds associations between clinical metadata and microbial community abundance or function. The clinical metadata can be of any type continuous (for example age and weight), boolean (sex, stool/biopsy), or discrete/factor (cohort groupings and phenotypes).  MaAsLin is best used in the case when you are associating many metadata with microbial measurements. When this is the case each metadatum can be a diffrent type.  For example, you could include age, weight, sex, cohort and phenotype in the same input file to be analyzed in the same MaAsLin run. The microbial measurements are expected to be normalized before using MaAsLin and so are proportional data ranging from 0 to 1.0
    License: MIT + file LICENSE
    VignetteBuilder: knitr
    Suggests: knitr, BiocStyle, BiocGenerics
    biocViews: Statistics, Metagenomics, Bioinformatics, Software
    Packaged: 2015-04-02 00:28:13 UTC; gweingart
--------------------------------------------------------
1.4 Qiime
#--------------------------------------------------------
1.4.1 Qiime version
#--------------------------------------------------------
      Version:      qiime 1.9.1
#--------------------------------------------------------
1.4.2 System information
#--------------------------------------------------------
               Platform:      Linux2
         Python version:      2.7.10 (default, Dec  4 2015, 15:36:19)  [GCC 4.4.7 20120313 (Red Hat 4.4.7-16)]
      Python executable:      /usr/local/bin/python
#--------------------------------------------------------
1.4.3 QIIME default reference information
#--------------------------------------------------------
For details on what files are used as QIIME's default references, see here:
https://github.com/biocore/qiime-default-reference/releases/tag/0.1.3
#--------------------------------------------------------
Dependency versions
===================
          QIIME library version:      1.9.1
           QIIME script version:      1.9.1
qiime-default-reference version:      0.1.3
                  NumPy version:      1.11.0
                  SciPy version:      0.17.1
                 pandas version:      0.17.1
             matplotlib version:      1.4.3
            biom-format version:      2.1.5
                   qcli version:      0.1.1
                   pyqi version:      0.3.2
             scikit-bio version:      0.2.3
                 PyNAST version:      1.2.2
                Emperor version:      0.9.51
                burrito version:      0.9.1
       burrito-fillings version:      0.1.1
              sortmerna version:      SortMeRNA version 2.0, 29/11/2014
              sumaclust version:      SUMACLUST Version 1.0.00
                  swarm version:      Swarm 1.2.19 [Dec  5 2015 16:48:11]
                          gdata:      Installed.
#--------------------------------------------------------
1.4.4 QIIME config values
#--------------------------------------------------------
For definitions of these settings and to learn how to configure QIIME, see here:
 http://qiime.org/install/qiime_config.html
 http://qiime.org/tutorials/parallel_qiime.html
#--------------------------------------------------------
QIIME config values
===================
For definitions of these settings and to learn how to configure QIIME, see here:
 http://qiime.org/install/qiime_config.html
 http://qiime.org/tutorials/parallel_qiime.html


                     blastmat_dir:      None
      pick_otus_reference_seqs_fp:      /usr/local/lib/python2.7/site-packages/q                                                                                                                                                             iime_default_reference/gg_13_8_otus/rep_set/97_otus.fasta
                    python_exe_fp:      python
                         sc_queue:      all.q
      topiaryexplorer_project_dir:      None
     pynast_template_alignment_fp:      /usr/local/data/core_set_aligned.fasta.i                                                                                                                                                             mputed
                  cluster_jobs_fp:      None
pynast_template_alignment_blastdb:      None
assign_taxonomy_reference_seqs_fp:      /usr/local/lib/python2.7/site-packages/q                                                                                                                                                             iime_default_reference/gg_13_8_otus/rep_set/97_otus.fasta
                     torque_queue:      friendlyq
              qiime_test_data_dir:      None
   template_alignment_lanemask_fp:      /usr/local/data/lanemask_in_1s_and_0s.tx                                                                                                                                                             t
                    jobs_to_start:      1
                       slurm_time:      None
                cloud_environment:      False
                qiime_scripts_dir:      /usr/local/bin
            denoiser_min_per_core:      50
                      working_dir:      None
assign_taxonomy_id_to_taxonomy_fp:      /usr/local/lib/python2.7/site-packages/q                                                                                                                                                             iime_default_reference/gg_13_8_otus/taxonomy/97_otu_taxonomy.txt
                         temp_dir:      /tmp/
                     slurm_memory:      None
                      slurm_queue:      None
                      blastall_fp:      blastall
                 seconds_to_sleep:      2
#--------------------------------------------------------
#########################################################
1.5 BBMap
#-------------------------------------------------------
    BBTools bioinformatics tools, including BBMap.
    Author: Brian Bushnell, Jon Rood
    Language: Java
    Version 36.32
#--------------------------------------------------------
#########################################################
2 Demo data
#--------------------------------------------------------
#########################################################
#--------------------------------------------------------
2.1 original sequences
#--------------------------------------------------------
     format of sequences :      fastq
       Number of fq files:      36
             fq_filenames:      1.Clean_FCHVJVMBCXX_L1_wHAXPI034525-109_1.fq
                                1.Clean_FCHVJVMBCXX_L1_wHAXPI034525-109_2.fq
                                1.Clean_FCHVJVMBCXX_L2_wHAXPI034525-109_1.fq
                                1.Clean_FCHVJVMBCXX_L2_wHAXPI034525-109_2.fq
                                1.Clean_FCHVTWCBCXX_L1_wHAXPI034526-108_1.fq
                                1.Clean_FCHVTWCBCXX_L1_wHAXPI034526-108_2.fq
                                1.Clean_FCHVTWCBCXX_L2_wHAXPI034526-108_1.fq
                                1.Clean_FCHVTWCBCXX_L2_wHAXPI034526-108_2.fq
                                2.Clean_FCHVJVMBCXX_L1_wHAXPI034525-109_1.fq
                                2.Clean_FCHVJVMBCXX_L1_wHAXPI034525-109_2.fq
                                2.Clean_FCHVJVMBCXX_L2_wHAXPI034525-109_1.fq
                                2.Clean_FCHVJVMBCXX_L2_wHAXPI034525-109_2.fq
                                2.Clean_FCHVTWCBCXX_L1_wHAXPI034526-108_1.fq
                                2.Clean_FCHVTWCBCXX_L1_wHAXPI034526-108_2.fq
                                2.Clean_FCHVTWCBCXX_L2_wHAXPI034526-108_1.fq
                                2.Clean_FCHVTWCBCXX_L2_wHAXPI034526-108_2.fq
                                3.Clean_FCHVJVMBCXX_L1_wHAXPI034525-109_1.fq
                                3.Clean_FCHVJVMBCXX_L1_wHAXPI034525-109_2.fq
                                3.Clean_FCHVJVMBCXX_L2_wHAXPI034525-109_1.fq
                                3.Clean_FCHVJVMBCXX_L2_wHAXPI034525-109_2.fq
                                3.Clean_FCHVTWCBCXX_L1_wHAXPI034526-108_1.fq
                                3.Clean_FCHVTWCBCXX_L1_wHAXPI034526-108_2.fq
                                3.Clean_FCHVTWCBCXX_L2_wHAXPI034526-108_1.fq
                                3.Clean_FCHVTWCBCXX_L2_wHAXPI034526-108_2.fq
                                4.Clean_FCHVJVMBCXX_L1_wHAXPI034525-109_1.fq
                                4.Clean_FCHVJVMBCXX_L1_wHAXPI034525-109_2.fq
                                4.Clean_FCHVJVMBCXX_L2_wHAXPI034525-109_1.fq
                                4.Clean_FCHVJVMBCXX_L2_wHAXPI034525-109_2.fq
                                4.Clean_FCHVTWCBCXX_L1_wHAXPI034526-108_1.fq
                                4.Clean_FCHVTWCBCXX_L1_wHAXPI034526-108_2.fq
                                4.Clean_FCHVTWCBCXX_L2_wHAXPI034526-108_1.fq
                                4.Clean_FCHVTWCBCXX_L2_wHAXPI034526-108_2.fq
                                5.Clean_FCHVJVMBCXX_L1_wHAXPI034525-109_1.fq
                                5.Clean_FCHVJVMBCXX_L1_wHAXPI034525-109_2.fq
                                5.Clean_FCHVJVMBCXX_L2_wHAXPI034525-109_1.fq
                                5.Clean_FCHVJVMBCXX_L2_wHAXPI034525-109_2.fq
#--------------------------------------------------------
#########################################################
#--------------------------------------------------------
2.2 metadata
#--------------------------------------------------------
     Filename:       Additional file 2: Table S1
       Header:       #SampleID	county_level_code	age	gender	Bristol_stool_type	fam_income_year_avg	fam_spend_year_avg
                      MetS	anthrop_waist	anthrop_SBP	anthrop_DBP	biochem_FBG	biochem_TG	biochem_HDL
    Row.names:       6896 SampleIDs
#--------------------------------------------------------
#########################################################
3 Scripts
#--------------------------------------------------------
#########################################################
#--------------------------------------------------------
3.1 Perl Scripts
#--------------------------------------------------------
3.1.1 Preprocessing.pl
#--------------------------------------------------------
         Function:      Pipline of preprocessing, this script performs all processing steps through building the OTU table with several pair of fastq file.
      Last updata:      2016-09-18
           Author:      Huimin Zheng
#--------------------------------------------------------
3.1.2 Relate_metadata_with_microbiota.pl
#--------------------------------------------------------
         Function:      Pipline of geting main results of the paper-Population-based survey linking gut microbiome to economic development and metabolic syndrome.
      Last updata:      2017-04-18
           Author:      Huimin Zheng
#--------------------------------------------------------
3.1.3 Illumina_pairend_preprocessing.pl
#--------------------------------------------------------
         Function:      This script performs all processing steps through building the OTU table with one pair of fastq file.
         Location:      Called by the pipeline--Preprocessing.pl
      Last updata:      2016-08-08
           Author:      Yan He
#--------------------------------------------------------
3.1.4 trim_200bp.pl
#--------------------------------------------------------
         Function:      Trim the fastq file to 200bp, this can reduce the computational burden while using enough information to do overlapping
         Location:      Called by the script--Illumina_pairend_preprocessing.pl
      Last updata:      2016-08-08
           Author:      Hua-Fang Sheng
#--------------------------------------------------------
3.1.5 pairend.extract_sequences.pl
#--------------------------------------------------------
         Function:      Do library splitting, as barcodes on both ends is not quite supported by QIIME at the moment (QIIME 1.9.1)
         Location:      Called by the script--Illumina_pairend_preprocessing.pl
      Last updata:      2016-08-08
           Author:      Yan He
#--------------------------------------------------------
3.1.6 merge_adiv_metadata.pl
#--------------------------------------------------------
         Function:      merge the alpha diversity file and metadata file.
         Location:      Called by the pipeline--Relate_metadata_with_microbiota.pl
      Last updata:      2016-08-08
           Author:      Yan He
#--------------------------------------------------------
3.1.7 adonis_dilution_curve.pl
#--------------------------------------------------------
         Function:      Examined the significance using adonis analysis on various subsampling sizes with specific replications at each size.
         Location:      Called by the pipeline--Relate_metadata_with_microbiota.pl
      Last updata:      2017-04-16
           Author:      Huimin Zheng
#--------------------------------------------------------
3.1.8 adonis_all_metadata.pl
#--------------------------------------------------------
         Function:      Do adonis analysis on all variables supplied. 
         Location:      Called by the script--adonis_dilution_curve.pl
      Last updata:      2016-08-08
           Author:      Yan He
#--------------------------------------------------------
3.1.9 adonis_dilution_curve_plot.pl
#--------------------------------------------------------
         Function:      Collect the adonis analysis results of script adonis_dilution_curve.pl and plot.
         Location:      Called by the script--Illumina_pairend_preprocessing.pl
      Last updata:      2017-04-16
           Author:      Huimin Zheng
#--------------------------------------------------------
3.1.10 maaslin_and_cytoscape.otu.pl
#--------------------------------------------------------
         Function:      Do MaAsLin analysis
         Location:      Called by the pipeline--Relate_metadata_with_microbiota.pl
      Last updata:      2016-08-08
           Author:      Yan He
#--------------------------------------------------------
3.1.11 add_taxa_to_map.pl
#--------------------------------------------------------
         Function:      Add relative abundance of taxa in taxa.list to metadata file.
         Location:      Called by the pipeline--Relate_metadata_with_microbiota.pl
      Last updata:      2017-04-16
           Author:      Huimin Zheng
#--------------------------------------------------------
3.1.12 collapsed_metadata.pl
#--------------------------------------------------------
         Function:      Collapse samples in metadata file. Values in the metadata file are collapsed by means of continuous variables and proportion of categorical variables for each group.
         Location:      Called by the pipeline--Relate_metadata_with_microbiota.pl
      Last updata:      2017-04-16
           Author:      Huimin Zheng
#--------------------------------------------------------
#########################################################
#--------------------------------------------------------
3.2 R Scripts
#--------------------------------------------------------
3.2.1 MetS_incidences_between_quartiles.R
#--------------------------------------------------------
         Function:      Calculate MetS incidences between quartiles and plot
         Location:      Called by the pipeline--Relate_metadata_with_microbiota.pl
      Last updata:      2017-04-16
           Author:      Pan Li
#--------------------------------------------------------
#########################################################
4 Supplementary files
#--------------------------------------------------------
#########################################################
#--------------------------------------------------------
4.1 metadata_category.txt
#--------------------------------------------------------
        Supplementary file of maaslin_and_cytoscape.otu.pl
#--------------------------------------------------------
4.2 taxa.list
#--------------------------------------------------------
        Supplementary file of add_taxa_to_map.pl
#--------------------------------------------------------
#########################################################
5 Direction for use
#--------------------------------------------------------
#########################################################
#--------------------------------------------------------
5.1 Configuring the system environment files and variables
#--------------------------------------------------------
Configuring the system environment files and variables based on the (1) Environment
#--------------------------------------------------------
#########################################################
#--------------------------------------------------------
5.2 Location of the files
#--------------------------------------------------------
put the scripts, bbmap folder and supplementary files in the same path
put all fastq files in the same path
#--------------------------------------------------------
#########################################################
#--------------------------------------------------------
5.3  modify Relate_metadata_with_microbiota.pl 
#--------------------------------------------------------
5.3.1  modify  Relate_metadata_with_microbiota.pl 
#--------------------------------------------------------
    line 39:   get the path of 97_otus.fasta, such as /usr/local/lib/python2.7/site-packages/qiime_default_reference/gg_13_8_otus/rep_set/97_otus.fasta
    line 51:   get the path of 97_otus.fasta, such as /usr/local/lib/python2.7/site-packages/qiime_default_reference/gg_13_8_otus/rep_set/97_otus.fasta
#--------------------------------------------------------
#########################################################
#--------------------------------------------------------
5.4 Run pipeline
#--------------------------------------------------------
5.4.1 Preprocessing: From raw sequences to BIOM
#-------------------------------------------------------- 
perl Preprocessing.pl <fq_dir> <metadata.list> <threads> <output_dir> 
<fq_dir>: Path to the folder containing all fastq files.
<metadata.list>: Path to file listing path to metadata file.
<threads>: Specify number of threads.
<output_dir>: The output directory.
# nohup perl Preprocessing.pl <fq_dir> <metadata.list> <threads> <output_dir> > Preprocessing.log 2>&1 &
#--------------------------------------------------------
5.4.2 Relate metadata with microbiota: From BIOM to downstream results
#--------------------------------------------------------
perl Relate_metadata_with_microbiota.pl <otu_table.biom> <metadata> <output_dir>
<otu_table.biom>: The input otu table filepath in biom format.
<metadata>: Path to the metadata file.
<output_dir>: The output directory.
#nohup perl Relate_metadata_with_microbiota.pl <otu_table.biom> <metadata> <output_dir> > Preprocessing.log 2>&1 &
#--------------------------------------------------------
#########################################################
