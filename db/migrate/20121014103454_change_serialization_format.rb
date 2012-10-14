class ChangeSerializationFormat < ActiveRecord::Migration
  def up
    Game.all.each do |game|
      %w( target guesses hints ).each do |attr|
        value = game.attributes_before_type_cast[attr].value

        next unless value =~ /^---/
        value = JSON.dump(YAML.load(value))
        game.attributes_before_type_cast[attr].value = value
        game.attributes_before_type_cast[attr].state = :serialized
      end

      game.save!
    end
  end

  def down
    raise IrreversibleMigration
  end
end
