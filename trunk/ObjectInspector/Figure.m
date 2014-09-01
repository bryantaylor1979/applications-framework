function handle = Figure
handle = figure;
warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
jframe=get(handle,'javaframe');
jIcon=javax.swing.ImageIcon('C:\Program Files\MATLAB\R2008a\toolbox\matlab\icons\pageicon.gif');
jframe.setFigureIcon(jIcon);
end