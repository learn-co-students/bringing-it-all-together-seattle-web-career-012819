class Dog

  attr_reader :id
  attr_accessor :name, :breed

  @@all = []

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed

    @@all << self
  end

  def self.all
    @@all
  end

  # creates table with all fields
  # .create_table -> []
  def self.create_table
    sql = <<~SQL
      CREATE TABLE dogs(
        id INTEGER PRIMARY KEY,
        name STRING,
        breed STRING
      );
    SQL

    DB[:conn].execute(sql)
  end

  
  # wipes out table
  # .drop_table -> []
  def self.drop_table
    sql = <<~SQL
    DROP TABLE IF EXISTS dogs;
    SQL
    
    DB[:conn].execute(sql)
  end

  # saves instance to database
  # checks if already present
  # #save -> []
  def save
    if self.id.nil?
      sql = <<~SQL
        INSERT INTO dogs(name, breed)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
      self
    else
      self
    end
  end

  # updates current Instance in DB
  # #update -> ?
  def update
    if id.nil?
      self.save
    else
      sql = <<~SQL
        UPDATE dogs
        SET name = ?, breed = ?
        WHERE id = ?;
      SQL

      DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
  end

  # creates class instance and saves to database
  # .create({name: String, breed: String}) -> Dog: instance
  def self.create(name:, breed:)
    dog = self.new(name: name, breed: breed)
    dog.save
  end

  # returns new Dog instance by id
  # .find_by_id(id: Integer) -> Dog: instance
  def self.find_by_id(id)
    sql = <<~SQL
        SELECT *
        FROM dogs
        WHERE dogs.id = ?;
    SQL

    id, name, breed = DB[:conn].execute(sql, id)[0]
    dog = self.new(id: id, name: name, breed: breed)
    dog.save
  end

  # instantiates if record exists but no instance exists
  # creates record and instance if none exists
  # returns instance
  # .find_or_create_by(name: String, breed: String) -> Dog: instance
  def self.find_or_create_by(name:, breed:)
    sql = <<~SQL
      SELECT *
      FROM dogs
      WHERE name = (?) AND breed = (?);
    SQL

    dogs = DB[:conn].execute(sql, name, breed)
    unless dogs.empty?
      id, name, breed = dogs.first
      self.new(id: id, name: name, breed: breed)
    else
      self.create(name: name, breed: breed)
    end
  end

  # creates instances of any records in database
  # without a matching class instance
  # .new_from_db -> [Dog: instances]
  def self.new_from_db(row)
    id, name, breed = row
    self.new(id: id, name: name, breed: breed)
  end

  # .find_by_name(name: String) -> Dog: instance
  def self.find_by_name(name)
    sql = <<~SQL
      SELECT * FROM dogs WHERE name = ?;
    SQL

    id, name, breed = DB[:conn].execute(sql, name)[0]

    self.new(id: id, name: name, breed: breed)
  end

end