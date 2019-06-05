require 'pry'
class Dog
  attr_accessor :name,:breed,:id

  def initialize(id:nil,name:,breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE dogs
    SQL

    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(hash)
    dog = Dog.new(name: hash[:name],breed: hash[:breed])
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE id =?
    LIMIT 1
    SQL

    DB[:conn].execute(sql,id).map {|row| self.new_from_db(row)}.first
  end

  def self.find_or_create_by(hash)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ? AND breed = ?
    SQL

    selected_dog = DB[:conn].execute(sql,hash[:name],hash[:breed]).first

    if selected_dog
      dog = self.new_from_db(selected_dog)
    else
      dog = self.create(hash)
    end
    dog
  end

  def self.new_from_db(array)
    new_dog = self.new(name:array[1],breed:array[2],id:array[0])
  end

  def self.find_by_name(given_name)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name =?
    LIMIT 1
    SQL

    DB[:conn].execute(sql,given_name).map {|row| self.new_from_db(row)}.first
  end

  def update
    sql = <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end #end of Dog class
