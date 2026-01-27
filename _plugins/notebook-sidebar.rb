#!/usr/bin/env ruby
# frozen_string_literal: true

module NotebookSidebar
  SIDEBAR_TITLE = "On This Page"
  DEFAULT_BRANCH = "main"

  # Entry point for the prerender hook
  def self.apply!(doc, site)
    return unless doc.respond_to?(:collection)
    return unless doc.collection && doc.collection.label == "notebooks"
    return if doc.data["sidebar"] && !doc.data["sidebar"].empty?

    notebook_path = notebook_path_from(doc.data)
    return if notebook_path.nil? || notebook_path.empty?

    relative_path = normalize_notebook_path(notebook_path)
    return if relative_path.empty?

    download_href = build_download_href(relative_path, site)
    nbviewer_href = build_nbviewer_href(relative_path, site)
    doc.data["sidebar"] = [
      {
        "title" => SIDEBAR_TITLE,
        "text" => sidebar_text(download_href, nbviewer_href)
      }
    ]
  end

  # Gets the notebook path element from the yaml frontmatter
  def self.notebook_path_from(data)
    data["notebook_ipynb"] || data["notebook_file"] || data["notebook"]
  end

  # Fixes the notebook path
  def self.normalize_notebook_path(raw)
    path = raw.to_s.strip
    path = path.sub(%r{\A\./}, "")
    path = path.sub(%r{\A/+}, "")
    path = path.sub(%r{\A_notebooks/}, "")
    path = path.sub(%r{\Anotebooks/}, "")
    path
  end

  # Creates the download button url
  def self.build_download_href(relative_path, site)
    baseurl = site.config["baseurl"].to_s
    path = File.join("notebooks", "notebooks", relative_path).gsub("\\", "/")
    joined = [baseurl, path].reject(&:empty?).join("/")
    href = "/#{joined}".gsub(%r{/+}, "/")
    href
    # repo = site.config["repository"].to_s.strip
    # repo_path = File.join("_notebooks", "notebooks", relative_path).gsub("\\", "/")
    # branch = DEFAULT_BRANCH
    # href = "https://raw.githubusercontent.com/#{repo}/refs/heads/#{branch}/#{repo_path}"
    return href
  end

  # Creates the NBViewer button url
  def self.build_nbviewer_href(relative_path, site)
    repo = site.config["repository"].to_s.strip
    branch = site.config["notebook_sidebar_branch"].to_s.strip
    branch = DEFAULT_BRANCH if branch.empty?
    repo_path = File.join("_notebooks", "notebooks", relative_path).gsub("\\", "/")
    return "" if repo.empty?

    "https://nbviewer.jupyter.org/github/#{repo}/blob/#{branch}/#{repo_path}"
  end

  # Builds the body of the sidbar text
  def self.sidebar_text(download_href, nbviewer_href)
    nbviewer_link = if nbviewer_href.to_s.empty?
        "[<i class='fas fa-fw fa-book'></i> NBViewer](#){: .btn .btn--info}"
    else
        "[<i class='fas fa-fw fa-book'></i> NBViewer](#{nbviewer_href}){: .btn .btn--info}"
    end

    # "[<i class='fas fa-fw fa-download'></i> Download Notebook](#{download_href}){: .btn .btn--success}",
    [
        "<a href='#{download_href}' class='btn btn--primary' download><i class='fas fa-fw fa-download'></i> Download Notebook</a>",
        nbviewer_link,
        "[<i class='fas fa-fw fa-arrow-up'></i> Back to Top](#site-nav){: .btn .btn--warning}"
    ].join("\n\n")
  end
end

# Run the prerender hook for each document
Jekyll::Hooks.register :documents, :pre_render do |doc, payload|
#   site = payload["site"]
    site = doc.site
  NotebookSidebar.apply!(doc, site)
end
