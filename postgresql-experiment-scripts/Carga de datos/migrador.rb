require "rubygems"
    require "json"
    require "csv"






    #Measure time
    start = Time.now
    i=0
    diferencia=0
    @referenceid=1
    labelfile = File.open("csv/labels.txt", "a")
    quialifierfile = File.open("csv/qualifiers.txt", "a")
    claimfile = File.open("csv/claims.txt", "a")
    entitiesfile = File.open("csv/entities.txt", "a")
    descriptionsfile = File.open("csv/descriptions.txt", "a")
    aliasesfile = File.open("csv/aliases.txt", "a")
    linksitesfile = File.open("csv/linksites.txt", "a")
    referencesfile = File.open("csv/references.txt", "a")
    references_snakfile = File.open("csv/references_snak.txt", "a")
    def deletebadchar (stringd)
      y= /[;\\\n]/
      h = {';' => '&&!!!&&', '\\' => '%%%$%', '\n' => '%%$!$%'}
      stringd.gsub(y,h).delete("\n").delete("\r").delete("\t")
    end
    File.open("dump.json", "r") do |f|
      f.each_line do |line|
        if i>0
        begin
          #Quitar la �ltima coma
          line.slice!(line.length-2,line.length)
          #Parsear json
          parsed = JSON.parse(line)
          #puts parsed.to_s
          #Limpiar variable correspondientes a las properties
          @property_datatype=''
          #Iterar sobre el json
          parsed.keys.each do |values|
            if values=='pageid'
              @pageid=parsed[values].to_s
            elsif values=='ns'
              @ns=parsed[values].to_s
            elsif values=='title'
              @title=parsed[values].to_s
              #puts @title
            elsif values=='lastrevid'
              @lastrevid=parsed[values].to_s
            elsif values=='modified'
              @modified=parsed[values].to_s
            elsif values=='id'
              @id=parsed[values].to_s
            elsif values=='type'
              @type=parsed[values].to_s
            elsif values=='datatype'
              @property_datatype=parsed[values].to_s
            elsif values=='labels'
              parsed[values].keys.each do  |label|
                labelfile <<  @id + "\t" + parsed[values][label]['language'].to_s + "\t" + deletebadchar(parsed[values][label]['value'].to_s) + "\n"
              end
            elsif values=='descriptions'
                parsed[values].keys.each do  |label|
                  descriptionsfile << @id + "\t" +  parsed[values][label]['language'].to_s + "\t" + deletebadchar(parsed[values][label]['value'].to_s) + "\n"
                end
            elsif values=='aliases'
              parsed[values].each do |aliase|
                aliase[1].each do |content|
                  aliasesfile << @id + "\t" + content['language'].to_s + "\t" + deletebadchar(content['value'].to_s) + "\n"
                end
              end
            elsif values=='claims'
              parsed[values].each do |claim|
                claim[1].each do |content|
                  @claimid=content['id']
                  @snaktype = content['mainsnak']['snaktype'].to_s
                  @property = content['mainsnak']['property'].to_s
                  @datatype = content['mainsnak']['datatype'].to_s
                  @datavalue = ''
                  @datavalue_string = ''
                  begin
                    @datavalue_type = content['mainsnak']['datavalue']['type'].to_s
                    if @datatype=='wikibase-item'
                      @datavalue = 'Q'<< content['mainsnak']['datavalue']['value']['numeric-id'].to_s
                    else
                      @datavalue_string = deletebadchar(content['mainsnak']['datavalue']['value'].to_s)
                    end
                  rescue Exception => e
                    @datavalue_string = 'novalue'
                  end
                  @claim_type = content['type']
                  @rank = content['rank']

                  if @datavalue_type=='time'

                    begin
                      @splited= @datavalue_string.split('=>')
                      @date1 = @splited[1]
                      @date1[0]=''
                      @date1[0]=''
                      @date2 = @date1.split('T')
                      @time = @date2[0]
                      @datavalue_date=@time

                      value2 = @datavalue_date.split("-")

                      if value2[0]=='0' || value2[0]=='00' || value2[0]=='000' || value2[0]=='0000'
                        value2[0]='1000'
                        #puts line
                      end
                      if value2[0].to_i>9999
                        value2[0]='9000'
                        puts line
                      end
                      if value2[1]=='00'
                        value2[1]='01'
                      end
                      if  value2[2]=='00'
                        #puts value2[2].to_i
                        value2[2]='01'
                      end

                    if value2[1]=='02' && value2[2].to_i>28
                        value2[2]='28'
                     # puts line
                    end
                    if value2[0].to_i>9999
                      value2[0]='9000'
                      puts line
                    end
                    if value2[1]=='00'
                      value2[1]='01'
                    end
                    if  value2[2]=='00'
                      #puts value2[2].to_i
                      value2[2]='01'
                    end

                  if value2[1]=='02' && value2[2].to_i>28
                      value2[2]='28'
                   # puts line
                  end
                  if value2[1]=='04' && value2[2].to_i>30
                    value2[2]='30'
                    puts line
                  end
                  if value2[1]=='06' && value2[2].to_i>30
                    value2[2]='30'
                    puts line
                  end
                  if value2[1]=='09' && value2[2].to_i>30
                    value2[2]='30'
                    puts line
                  end
                  if value2[1]=='11' && value2[2].to_i>30
                    value2[2]='30'
                    puts line
                  end

                  @datavalue_date= value2[0]+'-'+value2[1]+'-'+value2[2]
                  
                  if value2[1]=='00'
                    puts 'error'
                    break
                  end
                  if value2[2]=='00'
                    puts 'error'
                    break
                  end
                  puts @datavalue_date
                  rescue Exception => e
                    #puts @datavalue_string
                    @datavalue_date ='nodate'
                  end

                  else
                    @datavalue_date ='nodate'
                  end
                   
                    claimfile << @id + "\t" +@claimid+"\t"+@claim_type+"\t"+@rank+"\t"+@snaktype+"\t"+@property+"\t"+deletebadchar(@datavalue_string.to_s) + "\t" +  @datavalue + "\t" +@datavalue_date +"\t" +  @datavalue_type + "\t" + @datatype + "\n"
                    # deletebadchar(@datavalue_string.to_s)
                  #poner contador y estamos ready!
                  @counter =1
                  @positionh=1
                  @order_hash = Hash.new
                  if !content['qualifiers-order'].nil?
                    content['qualifiers-order'].each do |propertyorder|
                      @order_hash[propertyorder]=@positionh
                      @positionh=@positionh+1
                    end
                    if !content['qualifiers'].nil?
                      content['qualifiers'].each do |qualifier|
                        qualifier[1].each do |qcontent|
                          @qhash= qcontent['hash']
                          @qsnaktype= qcontent['snaktype']
                          @qproperty= qcontent['property']
                          @qdatatype= qcontent['datatype']
                          @qdatavalue= ''
                          @qdatavalue_string=''
                          @qvalue_type= qcontent['datatype']
                          begin
                            @qdatavalue_type = qcontent['datavalue']['type']
                            if @qdatatype=='wikibase-item'
                              @qdatavalue = 'Q'+ qcontent['datavalue']['value']['numeric-id'].to_s
                            else
                              @qdatavalue_string = qcontent['datavalue']['value']
                            end
                          rescue Exception => e
                            @qdatavalue_string = 'novalue'
                          end


                                   if @datavalue_type=='time'

                    begin
                      @splited= @qdatavalue_string.split('=>')
                      @date1 = @splited[1]
                      @date1[0]=''
                      @date1[0]=''
                      @date2 = @date1.split('T')
                      @time = @date2[0]
                      @datavalue_date=@time

                      value2 = @qdatavalue_date.split("-")

                      if value2[0]=='0' || value2[0]=='00' || value2[0]=='000' || value2[0]=='0000'
                        value2[0]='1000'
                        #puts line
                      end
                      if value2[0].to_i>9999
                        value2[0]='9000'
                        puts line
                      end
                      if value2[1]=='00'
                        value2[1]='01'
                      end
                      if  value2[2]=='00'
                        #puts value2[2].to_i
                        value2[2]='01'
                      end

                    if value2[1]=='02' && value2[2].to_i>28
                        value2[2]='28'
                     # puts line
                    end
                    if value2[0].to_i>9999
                      value2[0]='9000'
                      puts line
                    end
                    if value2[1]=='00'
                      value2[1]='01'
                    end
                    if  value2[2]=='00'
                      #puts value2[2].to_i
                      value2[2]='01'
                    end

                  if value2[1]=='02' && value2[2].to_i>28
                      value2[2]='28'
                   # puts line
                  end
                  if value2[1]=='04' && value2[2].to_i>30
                    value2[2]='30'
                    puts line
                  end
                  if value2[1]=='06' && value2[2].to_i>30
                    value2[2]='30'
                    puts line
                  end
                  if value2[1]=='09' && value2[2].to_i>30
                    value2[2]='30'
                    puts line
                  end
                  if value2[1]=='11' && value2[2].to_i>30
                    value2[2]='30'
                    puts line
                  end

                  @qdatavalue_date= value2[0]+'-'+value2[1]+'-'+value2[2]
                  
                  if value2[1]=='00'
                    puts 'error'
                    break
                  end
                  if value2[2]=='00'
                    puts 'error'
                    break
                  end
                   puts @qdatavalue_date
                  rescue Exception => e
                    #puts @datavalue_string
                    @qdatavalue_date ='nodate'
                  end

                  else
                    @qdatavalue_date ='nodate'
                  end
                  

                          quialifierfile << deletebadchar(@claimid.to_s) + "\t" + @eid.to_s + @property + "\t" + @qhash.to_s + "\t" + @qsnaktype.to_s + "\t" + @qproperty.to_s + "\t" + deletebadchar(@qdatavalue_string.to_s) + "\t" + @qdatavalue.to_s + "\t" +@datavalue_date +"\t" + "\t"+ @qdatavalue_type.to_s + "\t" + @qdatatype.to_s + "\t" + @counter.to_s + "\t" + @order_hash[qcontent['property']].to_s + "\n"
                           #seguir
                       #   Qualifier.create(claim_id:@claimid, eid: @eid,  pid: @property, hash_q: @qhash, snaktype: @qsnaktype, property: @qproperty, datatype: @qdatatype, value_string: @qdatavalue_string, value: @qdatavalue, order: @counter, value_type: @qdatavalue_type, qualifiers_order: @order_hash[qcontent['property']].to_i)
                          @counter= @counter+1
                        end
                      end
                    end
                  end

                  if !content['references'].nil?
                    content['references'].each do |reference|
                      @hash_r = reference['hash']
                      referencesfile << @referenceid.to_s + "\t" + deletebadchar(@hash_r.to_s) + "\t" + deletebadchar(@claimid.to_s) + "\n"
                      #@ref= Reference.create(hash_r: @hash_r, claim_id: @claimid)
                      @counters =1
                      @positions=1
                      @order_snak = Hash.new
                      if !reference['snaks-order'].nil?
                        reference['snaks-order'].each do |snaksorder|
                          @order_snak[snaksorder]=@positions
                          @positions=@positions+1
                        end
                        reference['snaks'].each do |snaks|
                          #Reference ID 	Snaktype 	Property 	Value string 	Value item 	Value type 	Datatype 	Order 	Reference order
                          snaks[1].each do |snak|
                            @snaktype_r= snak['snaktype'].to_s
                            @property_r= snak['property'].to_s
                            @datatype_r= snak['datatype'].to_s
                            @datavalue_r= ''
                            @datavalue_string_r=''
                            begin
                              @valuetype_r= snak['datavalue']['type']
                              if @datatype_r=='wikibase-item'
                                @datavalue_r = 'Q'+ snak['datavalue']['value']['numeric-id'].to_s
                              else
                                @datavalue_string_r = snak['datavalue']['value'].to_s
                              end
                            rescue Exception => e
                              @datavalue_string_r = ''
                            end
                            references_snakfile <<  @referenceid.to_s + "\t" + @snaktype_r.to_s + "\t" + @property_r.to_s + "\t" + deletebadchar(@datavalue_string_r.to_s) + "\t" + @datavalue_r.to_s + "\t" + @valuetype_r.to_s + "\t" + @datatype_r.to_s + "\t" + @counters.to_s + "\t" + @order_snak[@property_r].to_s + "\n"
                            #ReferencesSnaks2.create(reference_id: @ref.id, snaktype: @snaktype_r, property: @property_r, value_string:  @datavalue_string_r, value_item:  @datavalue_r, value_type:  @valuetype_r, datatype: @datatype_r, order:@counters, reference_order:  @order_snak[@property_r].to_i)
                            @counters= @counters+1

                          end
                        end
                        @referenceid+=1
                      end

                    end
                  end







                end
              end
            elsif values=='sitelinks'
              parsed[values].keys.each do  |link|
                linksitesfile << @id + "\t" +parsed[values][link]['site'].to_s + "\t" + parsed[values][link]['title'].to_s + "\n"
              end
            end
          end

            entitiesfile << @id + "\t" + @type + "\t" + @property_datatype.to_s + "\n"
          if i%1000==0
            puts 'entidad:' + i.to_s
            finish = Time.now
            diff = finish - start
            temp = diff- diferencia
            puts 'diferencia:' + temp.to_s
            diferencia = diff
            CSV.open("csv/graph.csv", "a") do |csv|
              csv << [ diff]
            end
          end

        rescue Exception => e
          CSV.open("csv/error.csv", "a") do |csv|
            puts e.to_s
            csv << [e.to_s]
          end
        end
        end
        i+=1
      end
    end
    #Ver el tiempo que demor�
    labelfile.close
    quialifierfile.close
    claimfile.close
    entitiesfile.close
    descriptionsfile.close
    aliasesfile.close
    linksitesfile.close
    referencesfile.close
    references_snakfile.close
    gets.chomp()