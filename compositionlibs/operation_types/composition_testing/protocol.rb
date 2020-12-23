# typed: false
# frozen_string_literal: true

needs 'CompositionLibs/AbstractComposition'
needs 'Standard Libs/Units'
needs 'Standard Libs/CommonInputOutputNames'

class Protocol
  include Units
  include CommonInputOutputNames

  def main
    composition = CompositionFactory.build(components: components,
                                           consumables: consumables,
                                           kits: kits)

    composition.make_component_items

    composition.kits.each { |kit| kit.composition.make_component_items }

    show do
      title 'Components'
      composition.components.each do |comp|
        note comp.item.to_s
      end
    end

    show do
      title 'Consumables'
      composition.consumables.each do |comp|
        note comp.input_name.to_s
      end
    end

    show do
      title 'Kit parts'
      composition.kits.each do |kit|
        note kit.input_name.to_s
        kit.composition.components.each do |comp|
          note comp.input_name.to_s
        end
        kit.composition.consumables.each do |cons|
          note cons.input_name.to_s
        end
      end
    end

    show do
      title 'Retrieve components'
      note composition.input(FRAGMENT).input_name.to_s
      note composition.input('Pipette Tips').input_name.to_s
      note composition.input('Modified CDC Kit').input_name.to_s
      note composition.input('Modified CDC Kit').composition.input('PBR').input_name.to_s
    end

    {}
  end

  def components
    [ 
      {
        input_name: FRAGMENT,
        qty: 16, units: MICROLITERS,
        sample_name: 'Test Specimen 1004',
        object_type: 'Nasopharyngeal Swab'
      },
      {
        input_name: 'Fragment 2',
        qty: 16, units: MICROLITERS,
        sample_name: 'Test Specimen 1002',
        object_type: 'Nasopharyngeal Swab'
      }
    ]
  end

  def consumables
    [
      {
        input_name: 'Pipette Tips',
        qty: 300, units: 'Each'
      }
    ]
  end

  def kits
    [
      {
        input_name: 'Modified CDC Kit',
        qty: 1, units: 'kits',
        components: [
          {
            input_name: 'PBR',
            qty: 16, units: 'Microliters',
            sample_name: 'Test Specimen 1004',
            object_type: 'Nasopharyngeal Swab'
          }
        ],
        consumables: [
          {
            input_name: 'Eppendorf Tubes',
            qty: 300, units: 'Each'
          }
        ]
      }
    ]
  end

end
