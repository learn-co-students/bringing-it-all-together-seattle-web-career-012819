class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY
      , name TEXT
      , breed TEXT
      )
      SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = 'DROP TABLE IF EXISTS dogs'

    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    new_dog = Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      SQL

    row = DB[:conn].execute(sql, name).first
    Dog.new_from_db(row)
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET
          name = ?
        , breed = ?
      WHERE id = ?
      SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
        SQL
      DB[:conn].execute(sql, self.name, self.breed)
      self.id = DB[:conn].execute("select * from dogs order by id desc limit 1")[0][0]
    end
    self
  end

  def self.create(**attr)
    new_dog = Dog.new(name: attr[:name], breed: attr[:breed])
    new_dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
      SQL

    row = DB[:conn].execute(sql, id).first
    Dog.new_from_db(row)
  end

  def self.find_or_create_by(**attr)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE
        name = ?
        and breed = ?
      SQL

    row = DB[:conn].execute(sql, attr[:name], attr[:breed]).first

    if !(row)
      Dog.create(attr)
    else
      Dog.new_from_db(row)
    end
  end
end
