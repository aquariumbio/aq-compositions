# frozen_string_literal: true

needs 'Standard Libs/Units'
needs 'Standard Libs/CommonInputOutputNames'

module AbstractCompositionDefinitions
  include Units
  include CommonInputOutputNames

  def components
    [
      input_name: FRAGMENT,
      qty: 16, units: MICROLITERS,
      sample_name: 'Test Specimen 1004',
      object_type: 'Nasopharyngeal Swab'
    ]
  end
end