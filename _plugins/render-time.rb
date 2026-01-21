module Jekyll
  class RenderTimeTagBlock < Liquid::Block

    def render(context)
      text = super
      "<p>#{text} #{Time.now}</p>"
    end

  end
end

Liquid::Template.register_tag('render_time', Jekyll::RenderTimeTagBlock)

# _plugins/jupyter_pluginer.rb
# module Jekyll
#   class RenderTimeTag < Liquid::Tag
#     def initialize(tag_name, text, tokens)
#       super
#       @text = text
#     end

#     def render(context)
#       "#{@text} #{Time.now}"
#     end
#   end
# end

# Liquid::Template.register_tag('render_time', Jekyll::RenderTimeTag)


# _plugins/nbconvert_notebooks.rb
# frozen_string_literal: true

# require "fileutils"
# require "open3"
# require "yaml"

# module NbconvertNotebooks
#   class Runner
#     def initialize(site)
#       @site = site
#       @cache_root = File.join(site.cache_dir, "nbconvert")
#       @assets_root = File.join(site.source, "assets", "notebooks")
#     end

#     def process!(doc)
#       return unless doc.respond_to?(:collection) && doc.collection.label == "notebooks"
#       return unless File.extname(doc.path).downcase == ".ipynb"

#       ipynb_path = doc.path
#       slug = File.basename(ipynb_path, ".ipynb")
#       cached_md_path = File.join(@cache_root, "notebooks", "#{slug}.md")
#       assets_dir = File.join(@assets_root, slug)

#       FileUtils.mkdir_p(File.dirname(cached_md_path))
#       FileUtils.mkdir_p(assets_dir)

#       if up_to_date?(ipynb_path, cached_md_path)
#         md = File.read(cached_md_path, encoding: "UTF-8")
#         apply_markdown!(doc, md)
#         return
#       end

#       md = nbconvert_markdown(ipynb_path, slug, assets_dir)
#       File.write(cached_md_path, md, mode: "w", encoding: "UTF-8")

#       apply_markdown!(doc, md)
#     end

#     private

#     def up_to_date?(src, cached)
#       return false unless File.exist?(cached)
#       File.mtime(cached) >= File.mtime(src)
#     end

#     def nbconvert_markdown(ipynb_path, slug, assets_dir)
#       # nbconvert file naming:
#       # --output sets the output *base name* (no extension)
#       # --output-dir sets the output directory :contentReference[oaicite:5]{index=5}
#       out_dir = Dir.mktmpdir("nbconvert-")
#       begin
#         cmd = [
#           "jupyter", "nbconvert",
#           "--to", "markdown",
#           "--output", slug,
#           "--output-dir", out_dir,
#           "--ExtractOutputPreprocessor.enabled=True",
#           # default template is like '{unique_key}_{cell_index}_{index}{extension}' :contentReference[oaicite:6]{index=6}
#           # We keep defaults but relocate extracted files after conversion.
#           ipynb_path
#         ]

#         stdout, stderr, status = Open3.capture3(*cmd)
#         unless status.success?
#           raise "nbconvert failed for #{ipynb_path}\nSTDOUT:\n#{stdout}\nSTDERR:\n#{stderr}"
#         end

#         md_path = File.join(out_dir, "#{slug}.md")
#         md = File.read(md_path, encoding: "UTF-8")

#         # Move extracted files (nbconvert typically puts them in a sibling folder like "#{slug}_files")
#         extracted_dir = File.join(out_dir, "#{slug}_files")
#         if Dir.exist?(extracted_dir)
#           # Copy files into /assets/notebooks/<slug>/
#           Dir.glob(File.join(extracted_dir, "**", "*")).each do |p|
#             next if File.directory?(p)
#             FileUtils.cp(p, assets_dir)
#           end

#           # Rewrite markdown links to point at site-root assets
#           # e.g. ![](my_notebook_files/xyz.png) -> ![](/assets/notebooks/<slug>/xyz.png)
#           md = md.gsub(%r{\(\s*#{Regexp.escape(slug)}_files/([^)\s]+)\s*\)}) do
#             "(/assets/notebooks/#{slug}/#{$1})"
#           end
#         end

#         md
#       ensure
#         FileUtils.remove_entry(out_dir) if out_dir && Dir.exist?(out_dir)
#       end
#     end

#     def apply_markdown!(doc, md)
#       # If nbconvert output starts with front matter, merge it into doc.data
#       # then strip it from content.
#       if md.start_with?("---\n")
#         parts = md.split(/^---\s*$\n/, 3) # ["", fm, rest]
#         if parts.length >= 3
#           fm_raw = parts[1]
#           body = parts[2]
#           fm_hash = YAML.safe_load(fm_raw) || {}
#           doc.data.merge!(fm_hash)
#           doc.content = body
#           return
#         end
#       end

#       doc.content = md
#     end
#   end
# end

# Jekyll::Hooks.register :documents, :pre_render do |doc, payload|
#   site = payload["site"]
#   NbconvertNotebooks::Runner.new(site).process!(doc)
# end
