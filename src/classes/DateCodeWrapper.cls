public class DateCodeWrapper {
  
    public String dateCode;
    public String source;

    public String parse(){
        return JSON.serialize(DateCodeWrapper.class, true);
    }
}