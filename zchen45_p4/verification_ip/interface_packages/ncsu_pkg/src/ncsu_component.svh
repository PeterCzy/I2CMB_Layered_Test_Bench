class ncsu_component#(type T=ncsu_transaction) extends ncsu_component_base;

  function new(string name="", ncsu_component_base  parent=null); 
    super.new(name);
    this.parent = parent;
  endfunction

  virtual function void build();
      ncsu_info("ncsu_component::build()", $sformatf(" of %s called",get_full_name()), NCSU_NONE);
  endfunction

  virtual task run();
      ncsu_info("ncsu_component::run()", $sformatf(" of %s called",get_full_name()), NCSU_NONE);
  endtask

  virtual task bl_put(input T trans); 
    ncsu_info("ncsu_component::bl_put()", $sformatf(" of %s called",get_full_name()), NCSU_NONE);
  endtask

  virtual function void nb_put(input T trans);
    ncsu_info("ncsu_component::nb_put()", $sformatf(" of %s called",get_full_name()), NCSU_NONE);
  endfunction

  virtual task bl_get(output T trans);
    ncsu_info("ncsu_component::bl_get()", $sformatf(" of %s called",get_full_name()), NCSU_NONE);
  endtask

  virtual function void nb_get(output T trans);
    ncsu_info("ncsu_component::nb_get()", $sformatf(" of %s called",get_full_name()), NCSU_NONE);
  endfunction

  virtual task bl_transport(input T input_trans, output T output_trans);
    ncsu_info("ncsu_component::bl_transport()", $sformatf(" of %s called",get_full_name()), NCSU_NONE);
  endtask

  virtual function void nb_transport(input T input_trans, output T output_trans);
    ncsu_info("ncsu_component::nb_transport()", $sformatf(" of %s called",get_full_name()), NCSU_NONE);
  endfunction

  virtual task wait_for_interrupt();
  endtask

  virtual task bl_get_dpr(output T trans);
  endtask

  virtual task bl_get_csr(output T trans);
  endtask

  virtual task wait_for_pos_clk();
  endtask

  virtual task init();
  endtask

  virtual task write_32();
  endtask

  virtual task read_32();
  endtask

  virtual task read();
  endtask

  virtual task write(input int temp);
  endtask

  virtual task rand_test();
  endtask

  virtual function void get_busid(output int bus_num);
  endfunction

endclass
