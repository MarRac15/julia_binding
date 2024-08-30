#include <string>
#include <vector>

class Cookie{
    public: 
        char* taste;
        int calories;

        Cookie(char* taste_, int calories_)
        : taste(taste_), calories(calories){};

        char* getTaste()
        {
            return taste;
        }

        int getCalories()
        {
            return calories;
        }

};


extern "C"{
    Cookie* Cookie_new(char* taste, int calories)
        {
            return new Cookie(taste, calories);
        }
    char* Cookie_getTaste(Cookie* obj)
        {
            return obj->getTaste();
        }
    int Cookie_getCalories(Cookie* obj)
        {
            return obj->getCalories();
        }
    void Cookie_delete(Cookie* obj)
        {
            delete obj;
        }
}