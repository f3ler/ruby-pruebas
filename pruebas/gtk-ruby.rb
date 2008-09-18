        #!/usr/bin/ruby -w         
        require 'gtk2' 
        Gtk.init 
        window = Gtk::Window.new 'Tiny Ruby/GTK Application' 
        label = Gtk::Label.new 'You are a trout!' 
        window.add label 
        window.signal_connect('destroy') { Gtk.main_quit } 
        window.show_all 
        Gtk.main 
