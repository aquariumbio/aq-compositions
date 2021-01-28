# frozen_string_literal: true

needs 'Standard Libs/ItemActions'
needs 'Standard Libs/AssociationManagement'
needs 'Standard Libs/Debug'
needs 'Small Instruments/Centrifuges'
needs 'Small Instruments/Shakers'
needs 'Small Instruments/Pipettors'

module CompositionHelper
  include ItemActions
  include AssociationManagement
  include Debug
  include Shakers
  include Centrifuges

  # Creates the adjusted quantities for components
  #
  # @param components [Components],
  # @param multi [Integer/Double]
  # @param round [Integer] how much to round
  def adjust_volume(components:, multi:, round: 1)
    components.each do |comp|
      comp.adjusted_qty(multi, round)
    end
  end

  # Instructions to create master mixes based on the modified qty
  #
  # @param components [Array<Component>]
  def create_master_mix(components:, master_mix:, adj_qty: false, vortex: true)
    show_block = []
    show_block.append("Add the following volumes to master mix item: #{master_mix}")
    components.each do |comp|
      unless comp.item.present?
        raise CompositionHelperError, "item #{comp.input_name} not present"
      end

      show_block.append(pipet(volume: comp.volume_hash(adj_qty: adj_qty),
                              source: comp.display_name,
                              destination: master_mix.display_name)
      )

    end
    show_block += shake(items: [master_mix.display_name], type: 'Vortex Mixer') if vortex
    components.each do |comp|
      item_to_item_vol_transfer(volume: comp.volume_hash(adj_qty: adj_qty),
                                key: 'volume_transfer',
                                to_item: comp.item,
                                from_item: master_mix.item)
    end
    show_block
  end

  # Sets the "item" of the components that relate to a specific kit
  # to the item of the kit.
  #
  # @param kit [KitContainer]
  # @param Composition [Composition]
  def set_kit_item(kit, composition)
    kit.components.each do |kit_comp|
      composition.input(kit_comp[:input_name]).item = kit.item
    end
  end

  # =========== Universal Method ========= #
  def volume_location_table(objects, adj_qty: false)
    location_table = create_location_table(objects)

    location_table.first.concat(['Quantity', 'Notes'])

    objects.each_with_index do |obj, idx|
      row = location_table[idx + 1]
      qty = obj.qty_display(adj_quantities: adj_qty)

      row.concat([qty, obj.notes || 'na'])
    end
    location_table
  end

  private

  def show_retrieve_parts(objects, adj_qty: true)
    return unless objects.present?
    show do
      title 'Retrieve Materials'
      note 'Please get the following materials'
      table volume_location_table(objects, adj_qty: adj_qty)
    end
  end
end

class CompositionHelperError < ProtocolError; end