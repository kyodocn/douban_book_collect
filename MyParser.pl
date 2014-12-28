 #!/perl -w
       
      use strict;
       
       # define the subclass
       package MyParser;
      use base "HTML::Parser";
       
       sub text {
          my ($self, $text) = @_;
         # just print out the original text
          print $text;
      }
      
      sub comment {
          my ($self, $comment) = @_;
          # print out original text with comment marker
          print "";
     }
      
      sub start {
          my ($self, $tag, $attr, $attrseq, $origtext) = @_;
         # print out original text
      print $origtext;
      }
     
      sub end {
          my ($self, $tag, $origtext) = @_;
          # print out original text
          print $origtext;
      }
1; 
      my $p = new MyParser;
      $p->parse_file("http://book.douban.com/subject_search?search_text=6%E5%8F%B7%E7%89%B9%E5%B7%A5&cat=1003");

