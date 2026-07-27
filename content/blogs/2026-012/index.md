---
post_id: "2026-012"
title: "GRAMMAR: Decoding the DNA sequence logic of genomic regulatory elements with the ENCODE deep learning model zoo"

# Optional: image filename "your-image.png" in the same folder
image: "encode_logo.png"

# Optional: Enable KaTeX for inline/block math (e.g. $10^{-K}$)
math: true

# Author(s): list of names (used for /authors/<slug>/)
authors: ["Chang M. Yun", "Vivekanandan Ramalingam", "Vivian Hecht", "Anshul Kundaje"]

# Optional: full details for citation, display and JSON-LD
authors_display:
  - name: "Chang M. Yun"
    affiliation: "Stanford University"
    orcid: "0000-0003-3793-8265"
  - name: "Vivekanandan Ramalingam"
    affiliation: "Stanford University"
    orcid: "0000-0002-3631-8913"
  - name: "Vivian Hecht"
    affiliation: "Stanford University"
    orcid: "0000-0003-4110-1388"
  - name: "Anshul Kundaje"
    affiliation: "Stanford University"
    orcid: "0000-0003-3084-2287"

editor: "Genomics X AI Editors"

# Set automatically by the submission form to the GitHub login of the original
# submitter. Used by the form to surface "Update one of my previous posts" for
# the same account on later revisions. Safe to omit when authoring manually.
submitter_github: "chang-m-yun"

# Add any number of tags. They're searchable on the blog homepage. See https://genomicsxai.github.io/tags/ for examples.
tags: ["encode", "genomics", "transcription-factor", "chromatin-accessibility", "ChIP-seq", "DNase-seq", "ATAC-seq", "seq2func"]
# Category determines which homepage pill filter the post appears under.
# Supported values: "Announcement", "Blog Post", "Tutorial", "Perspective", "Paper Reviews"
#   - "Announcement"  → appears under the Announcements pill (editorial/community announcements)
#   - "Blog Post"     → appears under the Blogs pill (default for most posts)
#   - "Tutorial"      → appears under the Tutorials pill (step-by-step technical guides)
#   - "Perspective"   → appears under the Perspectives pill (opinion pieces, commentary)
#   - "Paper Reviews" → appears under the Paper Reviews pill (summaries/critiques of a published paper)
# Note: the homepage pills filter by `categories` only, not by `scope`.
categories: ["Blog Post"]

# One or more: protocols, tutorials, negative-results, discussions, insights, ideas
scope: ["resource"]
# One or more: within-field, general, intro-to-field
audience: ["general"]
labs: ["Kundaje Lab"]

status: "submitted"
revision: 1

date_submitted: 2026-07-23
date_accepted: 
date: 2026-07-23

doi: ""
zenodo_url: ""
revision_history:
  - version: 1
    date: 2026-07-23
    notes: "Initial submission"
    # Optional: version-specific DOI / Zenodo record link
    doi: ""
    zenodo_url: ""
------

{{< summary >}}
Over two decades, the Encyclopedia of DNA Elements (ENCODE) Consortium has used diverse functional genomics experiments to map millions of regions in the human and mouse genomes that help control when, where, and how strongly genes are turned on. These maps characterize the biochemical properties and activity of regulatory DNA across thousands of cell types and tissues. However, they do not fully explain how this activity is encoded in the DNA sequence itself: which individual DNA letters are important, how combinations and arrangements of letters cause a region to behave differently across cell types, or how a genetic variant might alter its activity.
To help answer these questions, we developed a family of deep learning models that use DNA sequences as inputs to predict associated genome-wide biochemical activity measured by diverse experiments. We also developed a framework of model interpretation methods, allowing us to identify the sequence features and regulatory rules that drive model predictions. 
Today, we release GRAMMAR (Genomic Regulatory Atlas of sequence Models, Motifs, Annotations and Rules), a collection of 3,865 experiment-specific model sets across the ENCODE data compendium spanning several layers of gene regulation, including the binding of regulatory proteins to DNA, chromatin accessibility, transcription initiation, and regulatory activity measured using high-throughput reporter assays. For each experiment, we also release model-predicted de-noised biochemical activity profiles at single-base resolution; model-estimated contributions of individual DNA bases to the activity of each regulatory element in each cellular context; recurring predictive DNA patterns (motifs) learned by the models; the genomic locations of predictive motif instances; and genome-browser tracks that make these outputs easy to explore.
Together, these resources transform thousands of ENCODE experiments into a reusable and interpretable atlas of the cell-context-specific DNA sequence rules that shape gene regulation. In this first post of a broader series, we introduce the ENCODE GRAMMAR collection and show how predictions and sequence annotations derived from multiple models can be integrated to decode the sequence basis of regulatory element activity.
**Contributions**:
- Primary contributors: Vivekanandan Ramalingam, Chang M. Yun, Vivian Hecht, Aman Patel, Anusri Pampari, Ziwei Chen, Johannes Linder
- Secondary contributors: Georgi K. Marinov, Kelly Cochran, Abhimanyu Banerjee, Surag Nair, Salil S. Deshpande, Zahoor Zafrulla
- Tertiary contributors: Alex M. Tseng, Amr Alexandari, Mahfuza Sharmin, Avanti Shrikumar, Jacob M. Schreiber, Caleb Lareau
- Corresponding contributors: Anshul Kundaje
- Blog post: Chang M. Yun, Vivekanandan Ramalingam, Vivian Hecht _(equal contributions)_
{{< /summary >}}

> This post is the first of a series of blogs we will be releasing on GRAMMAR. We plan to release the following posts:
> 1. **SeqENCODE: Decoding the sequence basis of gene regulation across ENCODE with thousands of light-weight deep learning models (this post)**
> 1. Quickstart guide : How to access the ENCODE Deep Learning Collection
> 1. Understanding regulatory DNA using deep learning models
> 1. A guide to the DECODE BPNet model resource for modeling TF binding
> 1. A guide to the DECODE ChromBPNet resource for modeling chromatin accessibility
> 1. Case study #1: Predicting the effects of non-coding variant mutations
> 1. Case study #2: MotifCompendium: A unified lexicon of regulatory sequence motifs
> 1. Case study #3: Understanding cell type-specific activity of cis-regulatory elements
> 1. Postscript: successfully running production-scale projects in an academic setting

---
## DNA: not just genes
The human genome contains approximately 3.2 billion base pairs of DNA. While we often think of genes coding for proteins as the primary component of DNA, they account for only 1-2% of the genome. Gene expression, the process by which genes are converted into RNA, is a highly regulated process–genes are expressed at varying rates, and sometimes not at all–that is fundamental to the function of all living things. Many portions of the 98% of DNA not containing genes, also known as non-coding DNA, play a major role in regulating gene expression, as do the higher-order organization of DNA and various proteins that bind to it. 

DNA is packaged with proteins into chromatin and further organized into higher-order structures. Regulatory proteins, such as transcription factors (TFs), bind to DNA, then up- or down-regulate gene expression by further recruiting proteins involved in transcription. Similarly to thread wound around a spool, not all chromatin is accessible at all times, and binding of various TFs both influences and is determined by the accessibility of chromatin. Chromatin is highly cell- and species-specific, and plays an essential role in cell differentiation and responses to environmental stimuli such as nutrient stress; moreover, chromatin dysregulation can lead to improper interactions between regulatory elements and genes, which can in turn lead to cancer and other diseases. 
 
## ENCODE: An Encyclopedia of DNA Elements
The [**Encyclopedia of DNA Elements** (**ENCODE**) Consortium](https://www.encodeproject.org/), a public research project dedicated to building a comprehensive "Encyclopedia" of genome-wide regulatory elements has made major contributions towards characterizing the complex and diverse components of the regulatory landscape. We describe a few of the experimental methods that researchers in the field have developed to interrogate chromatin accessibility below.

**TF ChIP-seq**, or TF chromatin immunoprecipitation, is used to identify TF binding sites, one TF at a time, by using antibodies to bind a given TF that is, in turn, bound to particular regions of DNA. These bound regions are then isolated and sequenced, with reads accumulating at TF binding sites. TF-ChIP-seq datasets are typically analyzed to identify peaks from these accumulated reads. Short DNA sequences that are statistically enriched within these peaks can then be identified as candidate motifs that may contribute to transcription-factor binding.

![Figure: TF ChIP-seq](TFChIP.gif "width=300 Illustration of TF ChIP-seq: (1) TF binds to accessible DNA; (2) DNA is broken into fragments; (3) Antibodies bind to TF-DNA complex; (4) TF-DNA complex is pulled down; (5) Isolated DNA is cleaned and sequenced; (6) Sequences accumulate around the TF binding site.")

In **DNase-seq** and **ATAC-seq**, DNA-digesting enzymes (DNase I and Tn5 transposase, respectively) cut accessible chromatin into small fragments. These fragments are then isolated and sequenced, and accumulate in regions of open chromatin, analogously to TF-ChIP-seq. Worth noting is that DNase I and Tn5 transposase preferentially cut specific DNA sequences, leading to a slight bias in the form of an increased number of reads to particular regions. We discuss this further in subsequent sections.

![Figure: DNase-seq, ATAC-seq](ChromatinAccessibility.gif "width=300 Illustration of DNase-seq, ATAC-seq: (1) DNA can wrap around histones ('closed') or remain unwound ('open'); (2) Enzymes (DNase I or Tn5 transposase) cut accessible DNA; (3) DNA fragments are sequenced; (4) Accessible regions appear as peaks.")

In addition to chromatin accessibility and transcription factor binding, gene expression is further regulated in the moments preceding transcription. **PRO-cap** allows precise mapping of transcription start sites and quantifies active transcription in a cell, by mapping the 5' end of RNA from transcriptionally engaged RNA polymerases. 
 
And **MPRAs** and related high throughput reporter assays are used to experimentally measure whether particular sequences are in fact responsible for regulating gene expression. In general, in reporter assays, a candidate Cis-Regulatory Element, or cCRE, is inserted into a short sequence which also includes a measurable reporter output, such as a fluorescent molecule, or sequence barcodes in case of the high throughput versions. The greater the level of the measured reporter, the more active the regulatory element.

ENCODE has developed a set of approximately 16,000 standardized, uniformly processed datasets for the assays described above and many others, across a wide range of cell lines, primary cells and tissues. These are organized and publicly available for download via the [ENCODE portal](https://encodeproject.org). 

[Used the assays to map ~4 million candidate cis-regulatory elements: Explain cCRE, Enhancer, Promoter.]
The consortium recently released a preprint describing the newly included datasets in the fourth and final phase of the project [ENCODE 4](https://www.biorxiv.org/content/10.64898/2026.07.06.731365v1).

![Figure: ENCODE cube](ENCODE_cube.png "width=600 Coverage of the ENCODE Project: 100s of biochemical markers, performed in 100s of cell types and tissues, measured across 3 billion genomic positions. From Roadmap Epigenomics Consortium et al. Integrative analysis of 111 reference human epigenomes. Nature 518, 317–330 (2015). (https://doi.org/10.1038/nature14248)")
Coverage of the ENCODE Project: hundreds of biochemical markers, performed in hundreds of cell types and tissues, measured across 3 billion genomic positions. From _Roadmap Epigenomics Consortium et al. Integrative analysis of 111 reference human epigenomes. Nature 518, 317–330 (2015). ([https://doi.org/10.1038/nature14248](https://doi.org/10.1038/nature14248))_

However, while the experimental assays can help map the locations of active regulatory genomic elements, they provide limited mechanistic insights, and we are left with some fundamental questions, for example:

- *Which sequence features drive TF binding and chromatin accessibility? 
- *How do combinations and arrangements of motifs influence TF occupancy? 
- *What would happen if an individual nucleotide were altered? 
- *Is a disease-causing mutation causing its effect via changes to a transcription factor binding site?
 
## The BPNet family of deep learning models uncovers the quantitative role of sequence in regulation
Our group has developed a suite of deep learning models and downstream tools to address these questions. They include:
- **BPNet:** A convolutional neural network (CNN) trained on TF-ChIP-seq that predicts the binding of a TF from DNA sequence;
- **ChromBPNet:** A CNN with a BPNet-like architecture trained on DNase- or ATAC-seq that predicts chromatin accessibility from DNA sequence and corrects for enzymatic bias;
- **ProCapNet:** A CNN with a BPNet-like architecture trained on ProCAP-seq that predicts transcription initiation from DNA sequence;
- **ReporterNet:** A CNN with a BPNet-like architecture trained on MPRA data that predicts large-scale reporter assay signal from DNA sequence.

![Figure: ChromBPNet model architecture](ChromBPNet.png "width=600 Example BPNet-style model architecture with bias-correction: ChromBPNet. From Pampari, A. et al. ChromBPNet: bias factorized, base-resolution deep learning models of chromatin accessibility reveal cis-regulatory sequence syntax, transcription factor footprints and regulatory variants. 2024.12.25.630221 Preprint at https://doi.org/10.1101/2024.12.25.630221 (2024).")
Example BPNet-style model architecture with bias-correction: ChromBPNet. From _Pampari, A. et al. ChromBPNet: bias factorized, base-resolution deep learning models of chromatin accessibility reveal cis-regulatory sequence syntax, transcription factor footprints and regulatory variants. _bioRxiv_ 2024.12.25.630221 (2024). ([https://doi.org/10.1101/2024.12.25.630221](https://doi.org/10.1101/2024.12.25.630221))_

We describe the basic steps of our workflow below, with more detailed explanations available in the manuscripts [ChromBPNet, BPNet, ProCapNet, ReporterNet].

**1.** We begin by training a model that can reconstruct the observed experimental signal when provided the DNA sequence of the region. We expect that the model should only be able to perform this reconstruction by learning the underlying rules of chromatin regulation. While the input data varies based on assay, the basic model architecture remains the same.

![Figure: Train a model](BPNet_Fig1.gif "width=600 Train a model to predict experimentally observed signal from DNA sequence.")

DNase and ATAC-seq suffer from unwanted artifacts related to the preference of DNase and Tn5 to cut at specific sequence positions. Using ChromBPNet, we train a separate model to predict only the effects of the experimental artifact, and subtract its effect to isolate the regulatory signal.

![Figure: Remove bias](BPNet_Fig2.gif "width=600 Remove the effects of unwanted experimental artifacts, by training a separate model to predict the experimental effects then subtracting it from the total signal.")

**2.** We next interpret the relative activations of the trained model to understand which positions in the training sequences were most important to its predictions using DeepLIFT (ref). The most important positions, and bases at those positions, can often be directly attributed to the sequence binding preference of known transcription factors.   

![Figure: Interpret the model](BPNet_Fig4.gif "width=600 Identify highly contributing bases used by the model during prediction.")

**3.** Once we have the sequence interpretations, we use a suite of post-processing tools to extract, consolidate and cluster the potential transcription factor binding sites. We also map the sites back to the genome, which is very useful for downstream quantitative analyses. 

An example application, shown below, is to predict the effect of potentially disease-causing mutations in the genome. We can run predictions on mutations at any genomic sequence, even ones on which the model has not been trained, and calculate a log-fold change in signal, which can then be related to the mutation effect size. 

![Figure: Predict mutations](BPNet_Fig3.gif "width=600 Predict the effect of unseen mutations in the genome.")

In the following section, we share an example in the MYC locus to showcase the power of the models:

## Case study: Regulation in the MYC locus through the lens of deep learning models
The Myc family of proteins is a set of transcription factors that play an important role in cell proliferation, and mutations in the MYC gene have been shown to lead to many different types of cancer. Thus, understanding the mechanisms of regulation at the MYC locus with base-pair resolution can allow us to answer important questions relating to disease biology, Below, we view a CRISPRi-validated distal enhancer in the MYC locus [chr8:127,898,412—127,899,647] through the lens of 15 different models.

![Figure 1](MYC_fig0.png "width=600 MYC locus with a CRISPRi-validated distal enhancer [chr8:127,898,412—127,899,647] and its experimentally observed DNase-seq signal in K562.")

First, examining chromatin accessibility through ChromBPNet models: the models recapitulate the observed experimental profile with high concordance. Further, the models can de-noise the profile to isolate the true underlying accessibility signal, reconciling DNase and ATAC-seq experimental methods into agreement (where raw signals can diverge due to enzyme differences).
 
![Figure 2](MYC_fig2.png "width=600 Observed, model-predicted, and model-corrected DNase-seq and ATAC-seq profiles by ChromBPNet.")
 
Second, using the models, we highlight the key sequence drivers that the models identified to make their predictions (as "contribution scores"), and begin to see the underlying biological mechanism of regulation at this locus:

Examining the highly contributing sequences for chromatin accessibility through ChromBPNet, we observe key transcription factors (e.g., GATA, AP1, SP, ETV) that drive accessibility—in agreement with prior understanding.

In parallel, examining the key sequences for TF binding through BPNet, we observe the same sequences predict TF binding, in agreement with ChromBPNet—despite being trained on two entirely orthogonal assay types (TF ChIP-seq vs. DNase-seq/ATAC-seq).

![Figure 3](MYC_fig3.png "width=600 Highly contributing sequences used by the models during prediction. Insets compare contribution maps across DNase/ATAC (ChromBPNet), MPRA (ReporterNet), and TF ChIP-seq models (BPNet; e.g., GATA2, SP1, CEBPB, JUND, GABPB1), with high-impact motif instances annotated (e.g., GATA, SP, AP-1, ETV/ETS, CEBP).")
 
Below, we provide an interactive browser session of the exact locus to view dynamically:

{{< igv-browser panel="myc" data="myc-igv-panel.json" >}} 

## SeqENCODE: An 'Encyclopedia' of regulatory DNA deep learning sequence models
As part of ENCODE, we trained these models on hundreds of cell and tissue types available through the ENCODE consortium. We trained [BPNet](https://doi.org/10.1038/s41588-021-00782-6) models on 2,339 TF-ChIP-seq across 788 TFs, [ChromBPNet](https://doi.org/10.1101/2024.12.25.630221) models on 1,512 DNase-seq and ATAC-seq across 408 biosamples, [ProCapNet](https://doi.org/10.1101/2024.05.28.596138) models on 6 PRO-Cap, and ReporterNet models on 8 MPRAs to capture the dynamic regulatory activity across diverse samples. We release them together with the fourth and final phase of the ENCODE Project.
 
Through the power of the models and the richness of the ENCODE dataset, we hope to empower the community at large to explore important questions relating to the fundamental biology of gene regulation and mechanisms of disease in a wide variety of tissues and cell types. 

## How can I use the resource?
As part of the ENCODE Project, all data, models, analysis are available at the [Project portal](https://www.encodeproject.org/). If you use our models, please cite the [ENCODE preprint](https://doi.org/10.64898/2026.07.06.731365). 

Beyond the ENCODE portal, we provide several user-friendly alternatives for accessing and visualizing our data: 
- **Models**: We have uploaded the models for open access on the [ENCODE Portal](https://www.encodeproject.org/{ADD}) and on [**Hugging Face**](https://huggingface.co/collections/kundajelab/encode-bpnet-models)
- **Predictions**: We have created browser-friendly tracks of all model predictions in experimental peaks, as a [**UCSC Track Hub**](https://genome.ucsc.edu/cgi-bin/hgTracks?db=hg38&hubUrl=https://kundajelab.github.io/ucsc-trackhub-encode.github.io/hub.txt) for easy, interactive browser sessions
- **Sequence annotations**: We have identified highly contributing bases for all models and annotated the likely corresponding TF, as a [**UCSC Track Hub**](https://genome.ucsc.edu/cgi-bin/hgTracks?db=hg38&hubUrl=https://kundajelab.github.io/ucsc-trackhub-encode.github.io/hub.txt) for easy, interactive browser sessions
- **User guide**: We are currently building an _interactive_ user guide to help the community navigate and explain the resource (_work in progress_)
- **Preprint**: For more detail, the latest ENCODE preprint is out on [_bioRxiv_](https://doi.org/10.64898/2026.07.06.731365)
 
We still have so much to share about the resource! We are planning to regularly share the many different ways you can use the resource (~every week) for the foreseeable future, so give us a follow and be on the lookout for more.

## References
1. The ENCODE Project Consortium et al. The Encyclopedia of DNA Elements. _bioRxiv_ 2026.07.06.731365 (2026) ([https://doi.org/10.64898/2026.07.06.731365](https://doi.org/10.64898/2026.07.06.731365))
2. Avsec, Ž. et al. Base-resolution models of transcription-factor binding reveal soft motif syntax. _Nat Genet_ 53, 354—366 (2021). ([https://doi.org/10.1038/s41588-021-00782-6](https://doi.org/10.1038/s41588-021-00782-6))
3. Pampari, A. et al. ChromBPNet: bias factorized, base-resolution deep learning models of chromatin accessibility reveal cis-regulatory sequence syntax, transcription factor footprints and regulatory variants. _bioRxiv_ 2024.12.25.630221 (2024). ([https://doi.org/10.1101/2024.12.25.630221](https://doi.org/10.1101/2024.12.25.630221))
4. Cochran, K. et al. Dissecting the cis-regulatory syntax of transcription initiation with deep learning. _bioRxiv_ 2024.05.28.596138 (2024). ([https://doi.org/10.1101/2024.05.28.596138](https://doi.org/10.1101/2024.05.28.596138))
5. Yun, C. M. et al. A unified lexicon of predictive DNA sequence motifs from ENCODE transcription factor binding and chromatin accessibility assays. (2025) doi:10.5281/zenodo.17179111. ([https://doi.org/10.5281/zenodo.17179111](https://doi.org/10.5281/zenodo.17179111))
