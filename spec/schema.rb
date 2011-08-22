ActiveRecord::Schema.define :version => 0 do
  create_table "orders", :force => true do |t|
    t.column :name, :string
    t.timestamps  
  end


  create_table "sub_orders", :force => true do |t|
    t.column :order_id, :integer
    t.column :name, :string
    t.timestamps
  end
  
  create_table "order_items", :force => true do |t|
    t.column :sub_order_id, :integer
    t.column :name, :string
    t.timestamps
  end
end
