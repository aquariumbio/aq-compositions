# frozen_string_literal: true

needs 'Standard Libs/Units'

# Modules a component needed for a biochemical reaction
#
# Super class over both 'reagents'
class Component
  include Units

  attr_reader :input_name, :qty, :units
  attr_accessor :added, :location, :description, :lot_number, :adj_qty, :notes

  LOT_NUM = 'Lot_Number'

  def initialize(input_name:, qty:, units:, location: 'unknown',
                 description: nil, notes: 'na')
    @input_name = input_name
    @qty = qty
    @units = units
    @added = false
    @location = location
    @description = description
    @adj_qty = qty
    @lot_number = nil
    @notes = notes
  end

  # Checks if `self` has been added
  # @return [Boolean]
  def added?
    added
  end

  # The input name, formatted for display in protocols
  # @return [String]
  def display_name
    input_name
  end

  # To string method
  #
  # @return [String]
  def to_s
    input_name.to_s
  end

  # The volume as a qty, units hash
  #
  # @param adj_qty [Boolean] true if show adjusted quantity
  # @return [Hash]
  def volume_hash(adj_qty: false)
    { qty: adj_qty ? @adj_qty : @qty, units: units }
  end

  # Displays the volume (`qty`) with units
  #
  # @return [String]
  def qty_display(round = 1, adj_quantities: false)
    amount = if adj_quantities
               adj_qty
             else
               qty
             end
    amount = amount.round(round) unless amount.nil?
    Units.qty_display({ qty: amount, units: units })
  end

  # Adjusts the qty by a given factor and, if needed, makes it checkable
  #   in a table
  #
  # @param mult [Float] the factor to multiply `qty` by
  # @param round [FixNum] the number of places to round the result to
  # @param checkable [Boolean] whether to make the result checkable
  #   in a table
  # @return [Numeric, Hash]
  def adjusted_qty(mult = 1.0, round = 1)
    return if qty.nil?

    raise "Multiplier is nil for composition #{input_name}" if mult.nil?

    @adj_qty = (qty * mult).round(round)
  end
end


# Models a component of a biochemical reaction
# @author Devin Strickland <strcklnd@uw.edu>
# @author Cannon Mallory <strcklnd@uw.edu>
class ReactionComponent < Component
  attr_reader :sample, :item, :adj_qty, :object_type

  # Instantiates the class
  #
  # @param input_name [String] the name of the component
  # @param qty [Numeric] the quantity of this component to be added to
  #   a single reaction
  # @param units [String] the units of `qty`
  # @param sample_name [String] the name of the Aquarium Sample to be
  #   used for this component
  # @param object_name [String] the ObjectType (Container) that this
  #   component should be found in
  def initialize(input_name:, qty:, units:,
                 sample_name: nil, object_type: nil,
                 location: 'unknown', notes: 'na')
    super(input_name: input_name, qty: qty,
          units: units, location: location, notes: notes)
    @sample = sample_name ? Sample.find_by_name(sample_name) : nil
    @object_type = ObjectType.find_by_name(object_type) || object_type
    @item = nil
    @added = false
  end

  # Sets the description to the object_type string
  def description
    raise ReactionComponentError, "object_type for #{@input_name} is #{@object_type.class}" unless @object_type.present?
    if @object_type.is_a? String
      @object_type
    else
      @object_type.name.to_s
    end
  end

  # gets the location of the component
  def location
    @item&.location unless @item.nil?
    @location
  end

  # sets the location of the component item
  def location=(location)
    @item&.location = location
    @location = location
  end

  # To string method
  #
  # @return [String]
  def to_s
    if sample.nil?
      "#{input_name}-#{item}"
    else
      return "#{input_name}-#{item}" if sample.properties['Kit'] == 'true'

      return "#{sample.name}-#{item}" unless item.nil? || sample.nil?

      return sample.name.to_s unless sample.nil?

      input_name.to_s
    end
  end

  # Sets `item`
  #
  # @param item [Item]
  def item=(item)
    if item.collection?
      @item = item
    else
      if @sample
        unless @sample == item.sample
          raise ReactionComponentError, "Item / Sample mismatch, Item: #{item.sample.name}, Sample: #{@sample.name}"
        end
      else
        @sample = item.sample
      end
      @item = item
    end
    if object_type.nil?
      @object_type = item.object_type
    end
  end

end

class ReactionComponentError < ProtocolError; end
