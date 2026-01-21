---
title: "Jupyter Notebook Basics"
excerpt: "Interact with IPython/Jupyter notebooks."
layout: single
# classes: wide
toc: true
toc_icon: book
toc_sticky: true

header:
#   image: /assets/images/jupyter-logo.svg
  teaser: /assets/images/jupyter-logo.svg

# page_css:
#   - /assets/css/styles.css
sidebar:
  - title: "On This Page"
    text: "<a href='../notebooks/sample.ipynb' class='btn'><img src='/assets/icons/JUPYTER.svg' alt='Icon'></a>"
    # text: "[![download|32x32](/assets/icons/JUPYTER.svg)](../notebooks/sample.ipynb)"
    # text: "[<img src='/assets/icons/JUPYTER.svg' alt='drawing' height='64'/>](../notebooks/sample.ipynb)"
    # text: "Download at: ![Jupyter Notebook](https://img.shields.io/badge/jupyter-%23FA0F00.svg?style=for-the-badge&logo=jupyter&logoColor=white)"
    # text: "[download](../notebooks/sample.ipynb){.btn}"


# author_profile: true
---

Welcome!
This is the first "notebook" post for the ART Book website.
This is also an introduction to how notebooks flow for the whole site:

1. On the right-hand side of this page, you can see the table of contents for each of the headings of the notebook.
2. These posts insert a Jupyter/IPython notebook into the body, providing a way to just see all of the material on the website
3. If you want to run the notebook yourself, there is a button in the header of this page to download the notebook itself!

The notebook begins...now!

{% jupyter_notebook "./notebooks/sample.ipynb" to="markdown" %}

{% render_time %}
Page built at:
{% endrender_time %}
