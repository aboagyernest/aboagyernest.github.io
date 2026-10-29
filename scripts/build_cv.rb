#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'yaml'

ROOT = File.expand_path('..', __dir__)
DATA_DIR = File.join(ROOT, '_pages')
CV_DIR = File.join(ROOT, 'cv-source')
TEX_PATH = File.join(CV_DIR, 'Curriculum_Vitae.tex')
PDF_PATH = File.join(ROOT, 'files', 'Curriculum_Vitae.pdf')
BUILD_DIR = File.join(ROOT, '.cv-build')
STATIC_DIR = File.join(CV_DIR, 'static')
SKILLS_PATH = File.join(STATIC_DIR, 'skills.tex')

FileUtils.mkdir_p(CV_DIR)
FileUtils.mkdir_p(BUILD_DIR)

def data(name)
  YAML.load_file(File.join(DATA_DIR, "#{name}.yml"))
end


SITE = data('site')
APPOINTMENT = data('appointment')
INDUSTRY = data('industry')
EDUCATION = data('education')
INTERESTS = data('interests')
AWARDS = data('awards')
PUBLICATIONS = data('publications')
TEACHING = data('teaching')
ACTIVITIES = data('activities')
SERVICE = data('service')
OTHER_SERVICE = data('other_service')
MEMBERSHIPS = data('memberships')

LATEX_ESCAPE = {
  '\\' => '\\textbackslash{}',
  '&' => '\\&',
  '%' => '\\%',
  '$' => '\\$',
  '#' => '\\#',
  '_' => '\\_',
  '{' => '\\{',
  '}' => '\\}',
  '~' => '\\textasciitilde{}',
  '^' => '\\textasciicircum{}'
}.freeze

def html_to_latex(value)
  text = value.to_s.dup
  text.gsub!(/<strong>(.*?)<\/strong>/m, '\\textbf{\1}')
  text.gsub!(/<em>(.*?)<\/em>/m, '\\emph{\1}')
  text.gsub!(/<a\s+[^>]*href="([^"]+)"[^>]*>(.*?)<\/a>/m, '\2')
  text.gsub!(/<br\s*\/?\s*>/i, '\\\\')
  text.gsub!(/&mdash;/, '--')
  text.gsub!(/&nbsp;/, ' ')
  text.gsub!(/&amp;/, '&')
  text.gsub!(/&ldquo;/, '``')
  text.gsub!(/&rdquo;/, "''")
  text.gsub!(/↗/, '')
  text.gsub!(/—/, '--')
  text.gsub!(/–/, '--')
  text.gsub!(/·/, '\\textperiodcentered{}')
  text.gsub!(/’/, "'")
  text.gsub!(/<[^>]+>/, '')
  text
end

def escape_latex(value)
  html_to_latex(value).gsub(/[\\&%$#_{}~^]/) { |char| LATEX_ESCAPE.fetch(char) }
end

def trusted_latex(value)
  text = html_to_latex(value)
  escaped = text.gsub(/[&%$#_{}~^]/) { |char| LATEX_ESCAPE.fetch(char) }
  escaped.gsub(/\\(textbf|emph)\\\{([^{}]*)\\\}/) { "\\#{Regexp.last_match(1)}{#{Regexp.last_match(2)}}" }
         .gsub(/\\textperiodcentered\\\{\\\}/, '\\textperiodcentered{}')
end

def italicized_journals(journals)
  journals.to_s.split(/\s*,\s*/).map { |journal| "<em>#{journal}</em>" }.join(", ")
end

def section(title)
  "\\Needspace{6\\baselineskip}\n\\rule[4pt]{17cm}{0.3pt}\n\\medskip\n{\\large \\bf #{escape_latex(title)}}\n\\medskip\n\\nopagebreak[4]\n\n"
end

def two_column_rows(rows)
  body = rows.map do |left, right|
    "#{trusted_latex(left)} & #{trusted_latex(right)}\\\\"
  end.join("\n")

  <<~TEX
    \\begin{center}
    \\renewcommand{\\arraystretch}{1.5}%
    \\begin{tabular}{>{\\raggedright}m{13cm}>{\\raggedleft\\arraybackslash} m{3.5cm}}
    #{body}
    \\end{tabular}
    \\end{center}

  TEX
end

def itemize(items)
  body = items.map { |item| "  \\item #{trusted_latex(item)}" }.join("\n")
  "\\begin{itemize}\n#{body}\n\\end{itemize}\n\n"
end

def enumerate(items)
  body = items.map { |item| "  \\item #{trusted_latex(item)}" }.join("\n")
  "\\begin{enumerate}\n#{body}\n\\end{enumerate}\n\n"
end

def clean_venue(venue)
  trusted_latex(venue)
end

def venue_without_terminal_year(venue)
  venue.to_s.sub(/,\s*20\d{2}\s*\z/, '')
end

def publication_line(pub)
  authors = trusted_latex(pub['authors'])
  title = trusted_latex(pub['title'])
  year = pub['venue'].to_s[/\b(20\d{2})\b/, 1]
  venue = clean_venue(venue_without_terminal_year(pub['venue']))
  prefix = year ? "#{authors} (#{year})." : "#{authors}.".sub(/\.}?\.\z/) { |m| m[0..-2] }
  "#{prefix} #{title}. #{venue}.".gsub(/\s+/, ' ')
end


def award_year(label)
  label.to_s.split('·').first.to_s.strip
end

def award_source(label)
  label.to_s.split('·', 2)[1].to_s.strip
end

def without_links(value)
  value.to_s.gsub(/<a\s+[^>]*>(.*?)<\/a>/m, '\1')
end

tex = String.new
tex << <<~TEX
  \\documentclass[10pt]{article}
  \\pagestyle{empty}
  \\raggedbottom
  \\raggedright
  \\setlength{\\tabcolsep}{0in}
  \\usepackage{float}
  \\usepackage{array}
  \\usepackage{hyperref}
  \\usepackage{multirow}
  \\usepackage{needspace}
  \\urlstyle{same}
  \\addtolength{\\topmargin}{-6pc}
  \\addtolength{\\textheight}{10pc}
  \\addtolength{\\oddsidemargin}{-7pc}
  \\addtolength{\\textwidth}{12pc}
  \\setlength{\\evensidemargin}{\\oddsidemargin}
  \\setcounter{page}{1}
  \\renewcommand\\labelenumi{[\\theenumi]}
  \\begin{document}

  {\\Large \\bf #{escape_latex(SITE['name'])}, Ph.D., A.S.A.}
  \\medskip

  \\begin{tabular}{l l l}
      Departments of Mathematics \\& Statistics & ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Email: & ~~~~\\href{mailto:#{SITE['email']}}{#{escape_latex(SITE['email'])}}\\\\
      Purdue University & ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Website: & ~~~~\\url{#{SITE['website']}}
  \\end{tabular}
  \\medskip

TEX

tex << section('Employment')
tex << two_column_rows(APPOINTMENT.map { |item| ["#{item['title']}, #{without_links(item['detail'])}", item['year'].to_s.sub(/–\z/, '--present')] })
tex << "{\\bf Industry Experience}\n\n"
tex << two_column_rows(INDUSTRY.map { |item| ["#{item['title']}, #{item['detail']}", item['year']] })

tex << section('Education and Credentials')
tex << two_column_rows(EDUCATION.map { |item| ["#{item['degree']}, #{without_links(item['school'])}", item['year']] })

tex << section('Research Interests')
tex << itemize(INTERESTS)

tex << section('Publications and Manuscripts')
PUBLICATIONS.each do |group|
  tex << "{\\bf #{escape_latex(group['heading'])}}\n\n"
  tex << enumerate(group['items'].map { |pub| publication_line(pub) })
end

tex << section('Fellowships, Grants and Awards')
tex << two_column_rows(AWARDS.map { |award| ["#{without_links(award['title'])}, #{award_source(award['label'])}", award_year(award['label'])] })

tex << section('Presentations and Conferences')
ACTIVITIES.flat_map { |column| column['column'] }.each do |group|
  tex << "{\\bf #{escape_latex(group['heading'])}}\n\n"
  tex << two_column_rows(group['items'].map { |item| [[item['description'], item['place']].reject { |x| x.to_s.empty? }.join(', '), item['year'].to_s] })
end

tex << section('Teaching Experience')
TEACHING.each do |group|
  tex << "{\\bf #{escape_latex(group['heading'])}}\n\n"
  tex << two_column_rows(group['courses'].map { |course| ["#{course['code']} -- #{course['name']}", course['term']] })
end

tex << section('Service')
tex << "{\\bf Peer Review}\n\n"
tex << itemize(SERVICE.map { |item| "#{item['label']}: <em>#{item['journals']}</em>" })
tex << "{\\bf Other Service}\n\n"
tex << two_column_rows(OTHER_SERVICE.map { |item| [item['role'], item['year']] })
tex << "{\\bf Professional Memberships}\n\n"
tex << itemize(MEMBERSHIPS)

tex << File.read(SKILLS_PATH)
tex << "\n"

tex << <<~TEX
  \\rule[4pt]{17cm}{0.3pt}
  \\begin{center}
      {\\footnotesize Last updated: \\today}
  \\end{center}

  \\end{document}
TEX

File.write(TEX_PATH, tex)
puts "Generated #{TEX_PATH}"

unless ARGV.include?('--tex-only')
  command = ['pdflatex', '-interaction=nonstopmode', '-halt-on-error', '-output-directory', BUILD_DIR, TEX_PATH]
  2.times do
    system(*command, out: File::NULL) || abort('pdflatex failed')
  end
  built_pdf = File.join(BUILD_DIR, 'Curriculum_Vitae.pdf')
  if ARGV.include?('--draft-output')
    puts "Built draft PDF at #{built_pdf}"
  else
    FileUtils.cp(built_pdf, PDF_PATH)
    puts "Updated #{PDF_PATH}"
  end
end
