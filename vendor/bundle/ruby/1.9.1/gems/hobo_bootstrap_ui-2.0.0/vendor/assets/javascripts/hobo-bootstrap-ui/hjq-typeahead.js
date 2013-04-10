/* typeahead */
(function($) {
   $.fn.hjq_typeahead = function(annotations) {
     var opts = this.hjq('getOptions', annotations);
     if(annotations.completer_path) {
       opts.source = function (query, process) {
         return $.get(annotations.completer_path, { term: query }, function (data) {
           return process(data);
         });
       };
     }
     this.typeahead(opts);
   };
})( jQuery );
