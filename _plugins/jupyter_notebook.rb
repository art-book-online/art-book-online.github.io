# frozen_string_literal: true

require "fileutils"
require "open3"
require "shellwords"
require "tmpdir"

module Jekyll
  class JupyterNotebookTag < Liquid::Tag
    def initialize(tag_name, markup, tokens)
      super
      @markup = markup.to_s.strip
    end

    def render(context)
      site = context.registers[:site]
      page = context.registers[:page] || {}
      path, opts = parse_markup(@markup)
      return "<!-- jupyter_notebook: missing notebook path -->" if path.nil? || path.empty?

      ipynb_path = resolve_path(path, site, page)
      unless File.exist?(ipynb_path)
        return "<!-- jupyter_notebook: not found: #{path} -->"
      end

      to_format = (opts["to"] || opts["format"] || "html").downcase
      extra_args = opts["args"] ? Shellwords.split(opts["args"]) : []

      nbconvert(ipynb_path, to_format, extra_args)
    rescue StandardError => e
      "<!-- jupyter_notebook error: #{e.class}: #{e.message} -->"
    end

    private

    def parse_markup(markup)
      return [nil, {}] if markup.nil? || markup.empty?
      tokens = Shellwords.split(markup)
      return [nil, {}] if tokens.empty?

      path = tokens.shift
      opts = {}
      tokens.each do |token|
        key, val = token.split("=", 2)
        next if key.nil? || val.nil?

        val = val.gsub(/\A"(.*)"\z/m, '\1')
        val = val.gsub(/\A'(.*)'\z/m, '\1')
        opts[key] = val
      end

      [path, opts]
    end

    def resolve_path(path, site, page)
      if path.start_with?("/")
        File.join(site.source, path.sub(%r{\A/+}, ""))
      else
        base_dir = if page["path"]
                     File.dirname(File.join(site.source, page["path"]))
                   else
                     site.source
                   end
        File.expand_path(path, base_dir)
      end
    end

    def nbconvert(ipynb_path, to_format, extra_args)
      ext = output_extension(to_format)
      slug = File.basename(ipynb_path, ".ipynb")
      out_dir = Dir.mktmpdir("nbconvert-")
      begin
        cmd = ["jupyter", "nbconvert", "--to", to_format, "--output", slug, "--output-dir", out_dir]
        cmd.concat(extra_args)
        cmd << ipynb_path

        stdout, stderr, status = Open3.capture3(*cmd)
        unless status.success?
          raise "nbconvert failed for #{ipynb_path}\nSTDOUT:\n#{stdout}\nSTDERR:\n#{stderr}"
        end

        out_path = File.join(out_dir, "#{slug}.#{ext}")
        return File.read(out_path, encoding: "UTF-8") if File.exist?(out_path)

        fallback = Dir.glob(File.join(out_dir, "#{slug}.*")).first
        return File.read(fallback, encoding: "UTF-8") if fallback

        raise "nbconvert output not found for #{ipynb_path}"
      ensure
        FileUtils.remove_entry(out_dir) if out_dir && Dir.exist?(out_dir)
      end
    end

    def output_extension(to_format)
      normalized = to_format.downcase
      return "md" if normalized == "markdown" || normalized == "md"
      return "html" if normalized == "html"

      normalized
    end
  end
end

Liquid::Template.register_tag("jupyter_notebook", Jekyll::JupyterNotebookTag)
