class User
  attr_reader :id
  attr_accessor :fname, :lname

  def self.find_by_id(id)
    query = <<-SQL
    SELECT
      *
    FROM
      users
    WHERE
      id = ?
    SQL
    User.new(QuestionsDatabase.instance.execute(query, id)[0])
  end

  def self.find_by_name(fname, lname)
    query = <<-SQL
    SELECT
      *
    FROM
      users
    WHERE
      fname = ?
    AND
      lname = ?
    SQL
    users = []
    raw_users = QuestionsDatabase.instance.execute(query, fname, lname)
    raw_users.each do |entry|
      users << User.new(entry)
    end
    users
  end

  def initialize(options={})
    @id, @fname, @lname =
      options.values_at('id', 'fname', 'lname')
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(@id)
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_author_id(@id)
  end

  def followed_questions
    QuestionFollower.followed_questions_for_user_id(@id)
  end

  def save
    if self.id.nil?
      query = <<-SQL
      INSERT INTO
        users(id, fname, lname)
      VALUES
        (?, ?, ?)
      SQL
      QuestionsDatabase.instance.execute(query, @id, @fname, @lname)
      @id = QuestionsDatabase.instance.last_insert_row_id
    else
      query = <<-SQL
      UPDATE
        users
      SET
        fname = ?, lname = ?
      WHERE
        id = ?
      SQL
      QuestionsDatabase.instance.execute(query, @fname, @lname, @id)
    end
  end
end