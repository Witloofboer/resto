function menu = resto(day, language, location)
%RESTO RESTO(day, language, location) shows the VUB restaurant menu.
    if ~exist('language','var') || isempty(language)
        language = 'en';
    end
    if ~exist('day','var') || isempty(day)
        day = 'today';
    end
    if ~exist('location','var') || isempty(location)
        location = 'etterbeek';
    end
        
    switch lower(language)
        case {'en','eng','english','american'}
            url = 'https://my.vub.ac.be/en/restaurant';
            explan = 'The menu of';
        case {'nl','fl','flemish','dutch','nederlands','vlaams'}
            url = 'https://my.vub.ac.be/resto';
            explan = 'Het menu van';
        otherwise
            error('VUB:LanguageNotSpoken','We don''t speak that language');
    end
    
    switch lower(day)
        case {'today','vandaag','heden'}
            shift = 0;
        case {'tomorrow','morgen'}
            shift = 1;
        case {'overmorgen','day after tomorrow'}
            shift = 2;
        otherwise
            error('VUB:NotADay','We don''t know that day');
    end

    switch lower(location)
        case 'etterbeek'
            START_READ = 'menu-etterbeek';
            END_READ = 'menu-jette';
        case 'jette'
            START_READ = 'menu-jette';
            END_READ = 'menu-etterbeek';
        otherwise
            error('VUB:NotACampus', 'We don''t know that campus');
    end
    
    html = urlread(url);
    
    fragments = strsplit(html, START_READ);
    today = strsplit(fragments{2+shift}, END_READ);
    today = today{1};

    ENTRY_PATTERN = ['<tr><td style="border: 1px solid #000000;">(?<type>.*?)</td>\s',...
                     '<td style="border: 1px solid #000000;">(?<food>.*?)</td>\s</tr>'];

    menu = regexp(today, ENTRY_PATTERN, 'names');
    %% sanitize output
    sanitize = @(str) regexprep(str, '<\/?[b-zB-Z]+>', '');
    for iEntry = 1:numel(menu)
        menu(iEntry).food = sanitize(menu(iEntry).food);
    end
    
    sanitize = @(str) regexprep(str, '&amp;', '&');
    for iEntry = 1:numel(menu)
        menu(iEntry).food = sanitize(menu(iEntry).food);
    end

    %% output to console or argument
    if nargout == 0
        fprintf('%s %s:\n\n',explan, day);
        for iEntry = 1:numel(menu)
            fprintf('%30s : %s\n', menu(iEntry).type, menu(iEntry).food);
        end
        clear menu
    end

end