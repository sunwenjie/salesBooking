class ClientContact < Base
  establish_connection :xmo_production
  belongs_to :client, inverse_of: :client_contacts
end