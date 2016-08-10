# encoding: UTF-8
require 'pry'
require 'picky'
require 'csv'
require 'tf-idf-similarity'

puts "hello"
puts "WELCOME to the IR system!"
puts "initiailizing....."
@k1 = 1.2
@b = 0.75
@num_of_docs = Dir.glob(File.join('movies', '**', '*')).select { |file| File.file?(file) }.count
@docs_list = []
@document_length = {}
@document_word_frequency = {}
@meta_data = {}
@current_path = File.expand_path(File.dirname(__FILE__))
threshold = 0.05
stopwords_threshold = @num_of_docs*threshold

data = Picky::Index.new :movies do
  indexing removes_characters: /[^\p{Alpha}\p{Blank}]/i
  category :text, partial: Picky::Partial::None.new
end
Document = Struct.new :id, :text

puts "Fetching movies metadata......."
CSV.foreach("data.csv").with_index do |row, i|
  next if i == 0
  stringed_meta_data = (row - [row[0], row[1]]).join(" | ")
  @meta_data[row[0]] = stringed_meta_data
end

puts "Processing movies descriptions from files......."
Dir.foreach('movies') do |item|
  next if item == '.' or item == '..'
  item_serial_num = item.chomp(".txt")
  doc_text = File.read("movies/#{item}")
  doc_text_with_meta = @meta_data[item_serial_num] + "\n" + doc_text
  data.add Document.new(item_serial_num, doc_text)
  @docs_list << item_serial_num
  @document_length[item_serial_num] = doc_text.split.size
  @document_word_frequency[item_serial_num] = TfIdfSimilarity::Document.new(doc_text_with_meta).term_counts
end

@avgdl = @document_length.map{|k,v| v}.inject(:+) / @num_of_docs
inverted = data[:text].exact.inverted
@inv_count_hash = inverted.map{ |k,v| [k, v.count] }.to_h
inv_count = @inv_count_hash.sort_by{ |k,v| v}.reverse
@stopwords = inv_count.select{ |k,v| v > stopwords_threshold }.map{ |a| a[0] }

puts "Creating moviesFrequencyFile‬‬.csv......."
CSV.open("‫‪moviesFrequencyFile‬‬.csv", "wb") do |csv|
  inv_count.each{ |w| csv << w }
end

puts "Creating ‫‪moviesstopwords.txt......."
File.open("‫‪moviesstopwords.txt‬‬", "wb") do |f|
  f << @stopwords.join("\n")
end

puts "Creating inverted_index.csv......."
CSV.open("inverted_index.csv", "wb") do |csv|
  inverted.each do |k, arr|
    csv << [k]+arr unless @stopwords.include?k
  end
end
puts "-----===== SYSTEM INITIALIZATION COMPLETED =====-----"

query = ""
while true
  puts "@@@@@@@@@ PLEASE ENTER YOUR HEBREW QUERY, type 'bye' to exit @@@@@@@@@@"
  query = gets.chomp
  break if query == "bye"
  next if query == ""
  puts "@@@ PLEASE ENTER HOW MANY RESULTS @@@"
  num_res = gets.chomp.to_i
  results = bm25(query).first(num_res)
  File.open("results.txt", "wb") do |f|
    results.each do |res|
      f << stringify_result(res[0], res[1])
    end
  end
  puts "==== THE RESULTS ARE IN 'results.txt' FILE ===="
end
puts "bye bye"

BEGIN{
# encoding: UTF-8
  def bm25(query)
    @docs_list.map{ |d| [d, score(d, query)] }.to_h.sort_by{ |k,v| v}.reverse.to_h
  end

  def score(d, q)
    keywords = TfIdfSimilarity::Document.new(q).term_counts.map{ |k,v| k }
    keywords.map do |term|
      tf1 = tf(term, d)
      idf(term)*( (tf1*(@k1+1)) / (tf1+(@k1*(1-@b+(@b*(@document_length[d] / @avgdl))))))
    end.inject(:+)
  end

  def tf(term, d)
    @stopwords.include?(term) ? 0 : false || @document_word_frequency[d][term] || 0
  end

  def idf(term)
    n = ndc(term)
    Math.log( (@num_of_docs - n + 0.5) / (n + 0.5) )
  end

  def ndc(qi) # num of document containing qi
    @inv_count_hash[qi] || 0
  end

  def stringify_result(serialNum, score)
    return if score == 0
    "\n#{@meta_data[serialNum].sub(" | ", "\n")}\n
    #{File.read("movies/#{serialNum}.txt")}\n
    BM25 score: #{score}\n
    ===================================================="
  end
}
