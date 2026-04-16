module ApiClient                                                                                                                                                              
    include HTTParty                                                                                                                                                                    
    base_uri "/localhost/api/"                                                                                                                                              
                  
    def self.create(params)
      post('/todo_lists', body: params.to_json, headers: headers)
    end                                                                                                                                                                                 
   
    def self.update(id, params)                                                                                                                                                         
      put("/todo_lists/#{id}", body: params.to_json, headers: headers)
    end                                                                                                                                                                                 
   
    def self.destroy(id)                                                                                                                                                                
      delete("/todo_lists/#{id}", headers: headers)
    end

    def self.create_item(list_id, params)
      post("/todo_lists/#{list_id}/todo_items", body: params.to_json, headers: headers)
    end                                                                                                                                                                                 
   
    def self.update_item(list_id, id, params)                                                                                                                                                         
      put("/todo_lists/#{list_id}/todo_items/#{id}", body: params.to_json, headers: headers)
    end                                                                                                                                                                                 
   
    def self.destroy_item(list_id, id)                                                                                                                                                                
      delete("/todo_lists/#{list_id}/todo_items/#{id}", headers: headers)
    end

    def self.headers                                                                                                                                                                    
      { 'Content-Type' => 'application/json' }
    end                                                                                                                                                                                 
  end
