class Reply
  attr_reader :id
  attr_accessor :author_id, :parent_id, :question_id, :body

  def self.find_by_id(id)
    query = <<-SQL
    SELECT
      *
    FROM
      replies
    WHERE
      id = ?
    SQL
    Reply.new(QuestionsDatabase.instance.execute(query, id)[0])
  end

  def self.find_by_author_id (id) #called user id in assignment
    replies = []
    query = <<-SQL
    SELECT
      *
    FROM
      replies
    WHERE
      author_id = ?
    SQL

    raw_replies = QuestionsDatabase.instance.execute(query, id)
    raw_replies.each do |entry|
      replies << Reply.new(entry)
    end
    replies
  end

  def self.find_by_question_id (id)
    replies = []
    query = <<-SQL
    SELECT
      *
    FROM
      replies
    WHERE
      question_id = ?
    SQL

    raw_replies = QuestionsDatabase.instance.execute(query, id)
    raw_replies.each do |entry|
      replies << Reply.new(entry)
    end
    replies
  end

  def initialize(options={})
    @id, @author_id, @question_id, @body, @parent_id, =
      options.values_at('id', 'author_id', 'question_id', 'body', 'parent_reply')
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

  def question
    query = <<-SQL
    SELECT
      *
    FROM
      questions
    WHERE
      id = ?
    SQL
    Question.new(QuestionsDatabase.instance.execute(query, @question_id)[0])
  end

  def parent_reply
    query = <<-SQL
    SELECT
      *
    FROM
      replies
    WHERE
      id = ?
    SQL
    result = QuestionsDatabase.instance.execute(query, @parent_id)[0]
    result.nil? ? nil : Reply.new(QuestionsDatabase.instance.execute(query, @parent_id)[0])
  end

  def child_replies
    children = []
    query = <<-SQL
    SELECT
      *
    FROM
      replies
    WHERE
      parent_reply = ?
    SQL
    raw_children = QuestionsDatabase.instance.execute(query, @id)
    raw_children.each do |entry|
      children << Reply.new(entry)
    end
    children
  end

  def save
    if self.id.nil?
      query = <<-SQL
      INSERT INTO
        replies(id, question_id, parent_reply, author_id, body)
      VALUES
        (?, ?, ?, ?, ?)
      SQL
      QuestionsDatabase.instance.execute(query, @id, @question_id, @parent_id, @author_id, @body)
      @id = QuestionsDatabase.instance.last_insert_row_id
    else
      query = <<-SQL
      UPDATE
        replies
      SET
        question_id = ?, parent_reply = ?, author_id = ?, body = ?
      WHERE
        id = ?
      SQL
      QuestionsDatabase.instance.execute(query, @question_id, @parent_id, @author_id, @body, @id)
    end
  end
end