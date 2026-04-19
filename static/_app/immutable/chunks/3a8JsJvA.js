import"./CWj6FrbW.js";import"./CN51-NxK.js";import{b as Re,g as We,u as me,v as N,w as Ye,e as Be,j as n,i as g,k as m,c as s,r as o,t as x,x as i,l as fe,a as y,s as _,p as Oe,f as k,m as E,y as O,n as w}from"./1kn41hxb.js";import{i as Ke}from"./C2uoUl7y.js";import{a as b,r as K}from"./C6SlhMfL.js";import{b as L}from"./BeSTx8MJ.js";import{b as ve}from"./CMUIxxRJ.js";import{p as Le}from"./Bfc47y5P.js";import{i as ze}from"./BHodTn71.js";import{p}from"./BRELRuXV.js";import{a as _e,s as Je}from"./DE1znmLU.js";import{t as pe}from"./Dq8wgkFB.js";import{g as Qe}from"./BkztNnIE.js";import{u as Ve}from"./DRNw5k3H.js";import{u as Xe}from"./XG_o1fzr.js";import{C as Ze}from"./DBklaAqx.js";import{C as et}from"./55bIQCiS.js";import{C as tt}from"./DTv6bILL.js";import{T as S}from"./BlI3sRXj.js";import{A as rt}from"./DwuuPoFU.js";var at=k('<button class="w-full text-left text-sm py-1.5 px-1 rounded-lg dark:text-gray-300 dark:hover:text-white hover:bg-black/5 dark:hover:bg-gray-850" type="button"><!></button>'),st=k('<input class="w-full text-2xl bg-transparent outline-hidden" type="text" required/>'),ot=k('<div class="text-sm text-gray-500 shrink-0"> </div>'),it=k('<input class="w-full text-sm disabled:text-gray-500 bg-transparent outline-hidden" type="text" required/>'),lt=k('<input class="w-full text-sm bg-transparent outline-hidden" type="text" required/>'),nt=k('<div class="text-sm text-gray-500"><div class=" bg-yellow-500/20 text-yellow-700 dark:text-yellow-200 rounded-lg px-4 py-3"><div> </div> <ul class=" mt-1 list-disc pl-4 text-xs"><li> </li> <li> </li></ul></div> <div class="my-3"> </div></div>'),dt=k('<!> <div class=" flex flex-col justify-between w-full overflow-y-auto h-full"><div class="mx-auto w-full md:px-0 h-full"><form class=" flex flex-col max-h-[100dvh] h-full"><div class="flex flex-col flex-1 overflow-auto h-0 rounded-lg"><div class="w-full mb-2 flex flex-col gap-0.5"><div class="flex w-full items-center"><div class=" shrink-0 mr-2"><!></div> <div class="flex-1"><!></div></div> <div class=" flex gap-2 px-1 items-center"><!> <!></div></div> <div class="mb-2 flex-1 overflow-auto h-0 rounded-lg"><!></div> <div class="pb-3 flex justify-between"><div class="flex-1 pr-3"><div class="text-xs text-gray-500 line-clamp-2"><span class=" font-semibold dark:text-gray-200"> </span> <br/>— <span class=" font-medium dark:text-gray-400"> </span></div></div> <button class="px-3.5 py-1.5 text-sm font-medium bg-black hover:bg-gray-900 text-white dark:bg-white dark:text-black dark:hover:bg-gray-100 transition rounded-full" type="submit"> </button></div></div></form></div></div> <!>',1);function It(he,f){Re(f,!1);const v=()=>_e(Ve,"$user",z),e=()=>_e(xe,"$i18n",z),[z,ge]=Je(),xe=We("i18n");let q=E(null),M=E(!1),J=E(!1),$=p(f,"edit",8,!1),Q=p(f,"clone",8,!1),ye=p(f,"onSave",8,()=>{}),T=p(f,"id",12,""),C=p(f,"name",12,""),P=p(f,"meta",28,()=>({description:""})),h=p(f,"content",12,""),I=p(f,"accessGrants",28,()=>[]),A=E("");const we=()=>{g(A,h())};let D=E(),be=`import os
import requests
from datetime import datetime
from pydantic import BaseModel, Field

class Tools:
    def __init__(self):
        pass

    # Add your custom tools using pure Python code here, make sure to add type hints and descriptions
	
    def get_user_name_and_email_and_id(self, __user__: dict = {}) -> str:
        """
        Get the user name, Email and ID from the user object.
        """

        # Do not include a descrption for __user__ as it should not be shown in the tool's specification
        # The session user object will be passed as a parameter when the function is called

        print(__user__)
        result = ""

        if "name" in __user__:
            result += f"User: {__user__['name']}"
        if "id" in __user__:
            result += f" (ID: {__user__['id']})"
        if "email" in __user__:
            result += f" (Email: {__user__['email']})"

        if result == "":
            result = "User: Unknown"

        return result

    def get_current_time(self) -> str:
        """
        Get the current time in a more human-readable format.
        """

        now = datetime.now()
        current_time = now.strftime("%I:%M:%S %p")  # Using 12-hour format with AM/PM
        current_date = now.strftime(
            "%A, %B %d, %Y"
        )  # Full weekday, month name, day, and year

        return f"Current Date and Time = {current_date}, {current_time}"

    def calculator(
        self,
        equation: str = Field(
            ..., description="The mathematical equation to calculate."
        ),
    ) -> str:
        """
        Calculate the result of an equation.
        """

        # Avoid using eval in production code
        # https://nedbatchelder.com/blog/201206/eval_really_is_dangerous.html
        try:
            result = eval(equation)
            return f"{equation} = {result}"
        except Exception as e:
            print(e)
            return "Invalid equation"

    def get_current_weather(
        self,
        city: str = Field(
            "New York, NY", description="Get the current weather for a given city."
        ),
    ) -> str:
        """
        Get the current weather for a given city.
        """

        api_key = os.getenv("OPENWEATHER_API_KEY")
        if not api_key:
            return (
                "API key is not set in the environment variable 'OPENWEATHER_API_KEY'."
            )

        base_url = "http://api.openweathermap.org/data/2.5/weather"
        params = {
            "q": city,
            "appid": api_key,
            "units": "metric",  # Optional: Use 'imperial' for Fahrenheit
        }

        try:
            response = requests.get(base_url, params=params)
            response.raise_for_status()  # Raise HTTPError for bad responses (4xx and 5xx)
            data = response.json()

            if data.get("cod") != 200:
                return f"Error fetching weather data: {data.get('message')}"

            weather_description = data["weather"][0]["description"]
            temperature = data["main"]["temp"]
            humidity = data["main"]["humidity"]
            wind_speed = data["wind"]["speed"]

            return f"Weather in {city}: {temperature}°C"
        except requests.RequestException as e:
            return f"Error fetching weather data: {str(e)}"
`;const ke=async()=>{ye()({id:T(),name:C(),meta:P(),content:h(),access_grants:I()})},V=async()=>{if(n(D)){h(n(A)),await O();const r=await n(D).formatPythonCodeHandler();await O(),h(n(A)),await O(),r&&ke()}};me(()=>N(h()),()=>{h()&&we()}),me(()=>(N(C()),N($()),N(Q())),()=>{C()&&!$()&&!Q()&&T(C().replace(/\s+/g,"_").toLowerCase())}),Ye(),ze();var X=dt(),Z=Be(X);{let r=w(()=>(v(),i(()=>{var t,a,l,c;return((l=(a=(t=v())==null?void 0:t.permissions)==null?void 0:a.sharing)==null?void 0:l.tools)||((c=v())==null?void 0:c.role)==="admin"}))),d=w(()=>(v(),i(()=>{var t,a,l,c;return((l=(a=(t=v())==null?void 0:t.permissions)==null?void 0:a.sharing)==null?void 0:l.public_tools)||((c=v())==null?void 0:c.role)==="admin"}))),u=w(()=>(v(),i(()=>{var t,a,l,c;return(((l=(a=(t=v())==null?void 0:t.permissions)==null?void 0:a.access_grants)==null?void 0:l.allow_users)??!0)||((c=v())==null?void 0:c.role)==="admin"})));rt(Z,{accessRoles:["read","write"],get share(){return n(r)},get sharePublic(){return n(d)},get shareUsers(){return n(u)},onChange:async()=>{if($()&&T())try{await Xe(localStorage.token,T(),I()),pe.success(e().t("Saved"))}catch(t){pe.error(`${t}`)}},get show(){return n(J)},set show(t){g(J,t)},get accessGrants(){return I()},set accessGrants(t){I(t)},$$legacy:!0})}var j=m(Z,2),ee=s(j),G=s(ee),te=s(G),H=s(te),U=s(H),F=s(U),$e=s(F);{let r=w(()=>(e(),i(()=>e().t("Back"))));S($e,{get content(){return n(r)},children:(d,u)=>{var t=at(),a=s(t);tt(a,{strokeWidth:"2.5"}),o(t),x(l=>b(t,"aria-label",l),[()=>(e(),i(()=>e().t("Back")))]),fe("click",t,()=>{Qe("/workspace/tools")}),y(d,t)},$$slots:{default:!0}})}o(F);var re=m(F,2),Te=s(re);{let r=w(()=>(e(),i(()=>e().t("e.g. My Tools"))));S(Te,{get content(){return n(r)},placement:"top-start",children:(d,u)=>{var t=st();K(t),x((a,l)=>{b(t,"placeholder",a),b(t,"aria-label",l)},[()=>(e(),i(()=>e().t("Tool Name"))),()=>(e(),i(()=>e().t("Tool Name")))]),L(t,C),y(d,t)},$$slots:{default:!0}})}o(re),o(U);var ae=m(U,2),se=s(ae);{var Ce=r=>{var d=ot(),u=s(d,!0);o(d),x(()=>_(u,T())),y(r,d)},Ee=r=>{{let d=w(()=>(e(),i(()=>e().t("e.g. my_tools"))));S(r,{className:"w-full",get content(){return n(d)},placement:"top-start",children:(u,t)=>{var a=it();K(a),x((l,c)=>{b(a,"placeholder",l),b(a,"aria-label",c),a.disabled=$()},[()=>(e(),i(()=>e().t("Tool ID"))),()=>(e(),i(()=>e().t("Tool ID")))]),L(a,T),y(u,a)},$$slots:{default:!0}})}};Ke(se,r=>{$()?r(Ce):r(Ee,!1)})}var qe=m(se,2);{let r=w(()=>(e(),i(()=>e().t("e.g. Tools for performing various operations"))));S(qe,{className:"w-full self-center items-center flex",get content(){return n(r)},placement:"top-start",children:(d,u)=>{var t=lt();K(t),x((a,l)=>{b(t,"placeholder",a),b(t,"aria-label",l)},[()=>(e(),i(()=>e().t("Tool Description"))),()=>(e(),i(()=>e().t("Tool Description")))]),L(t,()=>P().description,a=>P(P().description=a,!0)),y(d,t)},$$slots:{default:!0}})}o(ae),o(H);var R=m(H,2),Pe=s(R);ve(Ze(Pe,{get value(){return h()},lang:"python",boilerplate:be,onChange:r=>{g(A,r)},onSave:async()=>{n(q)&&n(q).requestSubmit()},$$legacy:!0}),r=>g(D,r),()=>n(D)),o(R);var oe=m(R,2),W=s(oe),ie=s(W),Y=s(ie),Ie=s(Y,!0);o(Y);var le=m(Y),ne=m(le,3),Ae=s(ne,!0);o(ne),o(ie),o(W);var de=m(W,2),De=s(de,!0);o(de),o(oe),o(te),o(G),ve(G,r=>g(q,r),()=>n(q)),o(ee),o(j);var Ge=m(j,2);et(Ge,{get show(){return n(M)},set show(r){g(M,r)},$$events:{confirm:()=>{V()}},children:(r,d)=>{var u=nt(),t=s(u),a=s(t),l=s(a,!0);o(a);var c=m(a,2),B=s(c),Ne=s(B,!0);o(B);var ue=m(B,2),Se=s(ue,!0);o(ue),o(c),o(t);var ce=m(t,2),Me=s(ce,!0);o(ce),o(u),x((je,He,Ue,Fe)=>{_(l,je),_(Ne,He),_(Se,Ue),_(Me,Fe)},[()=>(e(),i(()=>e().t("Please carefully review the following warnings:"))),()=>(e(),i(()=>e().t("Tools have a function calling system that allows arbitrary code execution."))),()=>(e(),i(()=>e().t("Do not install tools from sources you do not fully trust."))),()=>(e(),i(()=>e().t("I acknowledge that I have read and I understand the implications of my action. I am aware of the risks associated with executing arbitrary code and I have verified the trustworthiness of the source.")))]),y(r,u)},$$slots:{default:!0},$$legacy:!0}),x((r,d,u,t)=>{_(Ie,r),_(le,` ${d??""} `),_(Ae,u),_(De,t)},[()=>(e(),i(()=>e().t("Warning:"))),()=>(e(),i(()=>e().t("Tools are a function calling system with arbitrary code execution"))),()=>(e(),i(()=>e().t("don't install random tools from sources you don't trust."))),()=>(e(),i(()=>e().t("Save")))]),fe("submit",G,Le(()=>{$()?V():g(M,!0)})),y(he,X),Oe(),ge()}export{It as T};
