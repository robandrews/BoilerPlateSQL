require 'sqlite3'
require 'singleton'
require_relative 'question'
require_relative 'user'
require_relative 'reply'
require_relative 'question_like'
require_relative 'question_follower'
require_relative 'tag'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize( file_path = $FILEPATH || "./db/questions.db" )
    super(file_path)
    self.results_as_hash = true
    self.type_translation = true
  end

end