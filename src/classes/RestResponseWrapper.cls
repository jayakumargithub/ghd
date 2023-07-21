/**
 * Created by Jayakumar Mogenahall on 01/02/2023.
 */

global with sharing class RestResponseWrapper {
    public RestResponseWrapper(){
        error = new ErrorWrapper();
        data = new data();
        result = '';


    }
    global String result;
    global ErrorWrapper error;
    global Data data;

    global class ErrorWrapper
    {
        global Integer errorId;
        global String errorText;
    }
    global class data
    {
        global String genericId;
    }


}