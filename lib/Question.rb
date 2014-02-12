class Question
  attr_reader :id
  attr_accessor :author_id, :title, :body

  def self.find_by_id(id)
    query = <<-SQL
    SELECT
      *
    FROM
      questions
    WHERE
      id = ?
    SQL
    Question.new(QuestionsDatabase.instance.execute(query, id)[0])
  end

  def self.find_by_author_id(id)
    questions = []
    query = <<-SQL
    SELECT
      *
    FROM
      questions
    WHERE
      author_id = ?
    SQL

    raw_questions = QuestionsDatabase.instance.execute(query, id)
    raw_questions.each do |data|
      questions << Question.new(data)
    end
    questions
  end


  def initialize(options={})
    @id, @author_id, @title, @body =
      options.values_at('id', 'author_id', 'title', 'body')
  end

  def author
    query = <<-SQL
    SELECT
      *
    FROM
      users
    WHERE
      id = ?
    SQL
    User.new(QuestionsDatabase.instance.execute(query, @author_id)[0])
  end

  def replies
    Reply.find_by_question_id(@id)
  end

  def followers
    QuestionFollower.followers_for_question_id(@id)
  end

  def self.most_followed(n)
    QuestionFollower.most_followed_questions(n)
  end

  def likers
    QuestionLike.likers_for_question_id(@id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(@id)
  end

  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
  end

  def save
    if self.id.nil?
      query = <<-SQL
      INSERT INTO
        questions(id, author_id, title, body)
      VALUES
        (?, ?, ?, ?)
      SQL
      QuestionsDatabase.instance.execute(query, @id, @author_id, @title, @body)
      @id = QuestionsDatabase.instance.last_insert_row_id
    else
      query = <<-SQL
      UPDATE
        questions
      SET
        author_id = ?, title = ?, body = ?
      WHERE
        id = ?
      SQL
      QuestionsDatabase.instance.execute(query, @author_id, @title, @body, @id)
    end
  end
end