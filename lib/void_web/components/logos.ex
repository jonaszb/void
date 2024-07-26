defmodule VoidWeb.Logos do
  use Phoenix.Component

  attr :class, :string, required: false, default: ""

  def logo_full(assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 240.78 102.453"
      class={["dark:fill-[#cdebf8] fill-[#0d455d]", @class || ""]}
    >
      <g>
        <path
          xmlns="http://www.w3.org/2000/svg"
          d="M9.707 80.686zm2.57 3.269a49.084 49.084 0 0 0 3.176 3.387c3.746 3.687 8.214 6.787 13.006 9.13 1.766.828 3.395 1.684 5.304 2.422.476.183.963.379 1.476.556.516.163 1.051.327 1.611.489.556.174 1.15.297 1.77.426.621.124 1.266.267 1.958.338a49.439 49.439 0 0 1-9.988-3.246 50.844 50.844 0 0 1-9.143-5.333c-5.715-4.187-10.604-9.562-14.175-15.707-.147-.184-.37-.534-.639-.98l-.431-.73-.435-.841c-.29-.583-.623-1.175-.878-1.748a38.624 38.624 0 0 0-.719-1.489c1.11 2.764 2.39 5.182 3.825 7.48a50.649 50.649 0 0 0 2.097 3.088c-.104-.14-.213-.277-.316-.418a51.483 51.483 0 0 0 2.492 3.165l.009.01zm-2.502-3.177-.068-.092.068.092zM.724 57.46l-.262-2.1c.139 1.282.3 2.714.594 4.148l-.177-1.018a12.983 12.983 0 0 1-.155-1.03zm45.774 43.095c3.604.365 7.384.256 11.087-.33 3.704-.583 7.328-1.618 10.696-2.952-6.204 2.44-12.789 3.525-19.23 3.344-.862-.014-1.712 0-2.553-.062z"
        /><path
          xmlns="http://www.w3.org/2000/svg"
          d="m25.156 93.18-.14-.088.14.089zm-.14-.088zm-1.362-.904zm6.732 3.874a45.427 45.427 0 0 0 9.278 3.151 46.93 46.93 0 0 1-14.508-6.032 45.405 45.405 0 0 0 5.23 2.881zm65.523-38.033c.053-.856.16-1.754.188-2.182.322-2.747.417-5.094.403-7.448-.06-.424-.23-1.219-.298-2.122-.083-.906-.204-1.793-.307-2.669-.157-.867-.292-1.726-.463-2.568 1.233 6.295 1.212 12.614.078 18.576a51.46 51.46 0 0 1 .4-1.587z"
        /><path
          xmlns="http://www.w3.org/2000/svg"
          d="M.48 45.235c.46-3.739 1.438-7.383 2.369-9.811L2.472 37.2c.233-.52.608-1.73 1.12-3.011l.37-.976.408-.947c.27-.613.498-1.194.738-1.64-.164.419-.322.869-.513 1.32-.187.454-.397.915-.596 1.378l.82-1.847a60.613 60.613 0 0 0-2.134 6.343c-.614 2.359-1.1 4.837-1.361 7.062-.076.555-.102 1.097-.152 1.614-.036.516-.099 1.01-.104 1.476-.023.931-.054 1.746-.038 2.399.057 1.305.135 1.956.248 1.592.223-.722.219-4.436.996-9.085a56.09 56.09 0 0 1 1.822-7.348c.803-2.492 1.856-4.908 2.947-7.04l-.32.7-.296.722-.605 1.458-.554 1.506-.283.76-.25.777c-.715 2.063-1.25 4.235-1.716 6.424l-.303 1.654c-.11.55-.158 1.109-.24 1.662-.172 1.106-.235 2.22-.331 3.321-.108 2.208-.13 4.388.07 6.473-.008-.495-.016-.935-.009-1.361l.062-1.276c.026-.438.022-.903.063-1.436.038-.533.072-1.133.103-1.843.212-3.581.851-7.126 1.846-10.556.949-3.445 2.067-6.48 3.733-9.228l.434-.827c.294-.555.538-1.102.849-1.66.354-.612.692-1.07.966-1.49.283-.416.522-.782.796-1.136l1.995-2.754c.041-.005-.011.1-.108.257a15.693 15.693 0 0 1 1.062-1.35c.409-.474.806-.977 1.142-1.392.08-.003.156-.006.338-.136 4.687-4.983 10.455-9.044 16.955-11.604l1.445-.563 1.463-.488.728-.242.737-.206 1.468-.408c.84-.202 1.69-.407 2.558-.591l1.32-.231c.445-.077.89-.163 1.347-.205.907-.109 1.698-.339 2.124-.395 2.368-.135 4.73-.108 7.504.117.216.004.55.023.939.044.388.023.833.033 1.264.073.505.114 1.044.227 1.61.337 3.45.535 6.787 1.492 9.962 2.765l-.004-.016 1.216.485 1.24.573c.852.37 1.686.845 2.548 1.291.432.22.842.49 1.266.734.418.257.854.484 1.258.765.817.543 1.645 1.063 2.409 1.643a54.138 54.138 0 0 1 3.576 2.817l.076.066.022.02.79.717.755.753.756.755c.25.253.482.524.725.785-.117-.19-.113-.266-.109-.342l-1.25-1.197c.727.662 1.362 1.26 1.883 1.75.201.256.42.509.629.785l.642.848.684.883.68.95c1.206 1.537 2.27 3.182 3.282 4.86.468.86.984 1.696 1.4 2.586l.658 1.32.592 1.353c.17.29.104.012.125-.036.664 1.604 1.198 3.273 1.68 4.955a47.798 47.798 0 0 1 1.847 9.326c.122.747.174 1.502.282 2.25l-.066 1.585c-.001.598.03 1.195.005 1.794l-.07 1.802c-.008.407-.067.85-.1 1.333-.046.48-.07 1-.14 1.547l-.223 1.73c-.071.606-.21 1.23-.316 1.88a49.11 49.11 0 0 1-2.336 8.39c-.131.447-.231.805-.32 1.005-.34.813-.703 1.6-1.053 2.376-.392.755-.751 1.51-1.153 2.226a46.648 46.648 0 0 1-4.307 6.707c-.182.238-.351.48-.535.703l-.54.653c-.358.422-.678.845-1.017 1.21-.678.733-1.247 1.413-1.78 1.924-.612.638-.557.668-.134.36a19.003 19.003 0 0 0 .872-.684l1.15-1.037c.42-.367.822-.78 1.21-1.17.384-.393.768-.752 1.064-1.076.596-.645.988-1.043.904-.866-.962 1.812-2.716 4.048-5.279 6.521-1.307 1.207-2.778 2.518-4.518 3.782-.849.662-1.792 1.267-2.754 1.928-.994.609-2.01 1.275-3.12 1.867-2.43 1.323 1.824-.8 1.939-.82a12.392 12.392 0 0 1-1.288.89c-.801.425-1.595.865-2.424 1.23-.485.224-.962.464-1.452.672l-1.479.608.783-.308c1.6-.635 3.094-1.384 4.444-2.125-.507.307-1.062.662-1.67.982-.652.337-1.327.706-2.003 1.034l-1.965.914c7.027-2.553 13.484-6.777 18.596-12.284 2.56-2.745 4.842-5.76 6.702-9.022a50.882 50.882 0 0 0 4.491-10.295 47.81 47.81 0 0 1-7.575 14.503c5.821-7.86 9.292-17.498 9.753-27.437-.001.547-.055 1.093-.092 1.639-.044.545-.066 1.093-.13 1.637-.14 1.087-.239 2.179-.448 3.256-.338 2.168-.887 4.298-1.508 6.402 1.226-3.804 1.958-7.816 2.246-11.85.3-4.037.05-8.099-.572-12.035 1.07 5.214 1.246 11.121.335 16.96.64-3.766.803-7.647.557-11.496-.055-1.47-.229-2.93-.371-4.28-.204-1.343-.359-2.581-.557-3.583.783 3.699 1.092 6.853 1.243 9.827-.145-6.49-1.49-13.065-4.13-19.242 1.442 3.355 2.625 6.964 3.347 10.674.726 3.706 1.028 7.498.856 11.146-.008-.427.01-.854-.015-1.282l-.058-1.296c.155 5.88-.75 11.706-2.545 17.186a50.484 50.484 0 0 1-3.36 7.935 51.758 51.758 0 0 1-4.637 7.215c1.99-2.324 4.091-5.61 5.768-9.22 1.67-3.616 2.909-7.528 3.761-10.944a49.814 49.814 0 0 1-7.353 17.594 50.112 50.112 0 0 1-13.776 13.818 49.63 49.63 0 0 1-17.982 7.45 51.264 51.264 0 0 1-9.568.98 51.185 51.185 0 0 1-9.407-.82l1.628.309c.543.103 1.094.16 1.64.24 1.092.176 2.197.242 3.298.344 2.207.124 4.426.165 6.638-.003 2.216-.118 4.417-.448 6.608-.852 1.087-.247 2.187-.449 3.26-.766.54-.15 1.084-.282 1.62-.45l1.6-.519c-.808.25-1.659.582-2.567.825l-1.139.335a49.727 49.727 0 0 0 6.995-2.436 48.474 48.474 0 0 0 3.062-1.466 52.372 52.372 0 0 1-5.805 2.64 53.322 53.322 0 0 1-11.737 2.917c-.601.095-1.15.125-1.64.176l-1.316.13c-.775.061-1.346.09-1.746.133-.8.08-.914.154-.596.215.318.061 1.068.11 1.99.136.92-.005 2.01-.055 3.003-.145A50.75 50.75 0 0 0 81.72 91.516c7.34-5.858 12.96-13.64 16.094-22.469.197-.512.348-1.041.511-1.566.16-.526.335-1.046.478-1.577.266-1.068.581-2.123.785-3.207l.335-1.617.264-1.632.13-.817.094-.822.185-1.644c.379-4.396.229-8.84-.44-13.2-.357-2.468-.986-5.398-1.796-8.008l-.623-1.888c-.217-.6-.447-1.165-.652-1.697l-.302-.767-.31-.689-.53-1.15c-1.699-3.446-3.833-6.733-6.33-9.79-2.496-3.057-5.363-5.888-8.595-8.353L79.802 9.7l-1.26-.871-.633-.437-.651-.41-1.31-.817c-1.785-1.032-3.614-2.026-5.542-2.85-1.908-.867-3.905-1.57-5.937-2.198-1.027-.282-2.049-.596-3.102-.812-.524-.113-1.044-.251-1.575-.346L58.197.677C54.382.006 50.414-.154 46.45.144 42.488.45 38.51 1.202 34.694 2.5l-1.428.495c-.477.16-.937.37-1.407.552-.465.195-.94.365-1.396.58l-1.372.635c-.462.204-.908.438-1.353.675l-1.338.702-1.301.765c-.434.256-.87.506-1.285.79l-1.26.828c-.423.27-.816.584-1.225.874-.401.3-.818.58-1.206.896l-1.169.941c-.395.306-.768.639-1.14.971l-1.117.992-1.068 1.04c-.356.346-.715.688-1.046 1.057-2.726 2.87-5.121 6.002-7.08 9.316a53.924 53.924 0 0 0-4.696 10.275c-2.37 7-3.05 14.1-2.734 20.514-.068-2.64-.08-6.426.408-10.163zm76.474 49.009a52.455 52.455 0 0 0 4.749-3.462c-1.539 1.267-3.12 2.437-4.75 3.462zM98.745 64.83c-.162.488-.299.97-.478 1.43l-.518 1.368-.253.676-.278.667a58.813 58.813 0 0 0-.54 1.355 52.726 52.726 0 0 1-3.569 7.234c-1.366 2.316-2.95 4.487-4.641 6.524-.836 1.029-1.746 1.983-2.641 2.937l-1.399 1.367c-.458.46-.96.87-1.437 1.303-.398.347-.8.686-1.205 1.02a49.144 49.144 0 0 0 4.278-3.962 48.663 48.663 0 0 1-6.333 5.52c-.562.391-1.104.81-1.687 1.18l-1.76 1.12-1.858 1.056c-.632.351-1.3.664-1.97 1.005a40.209 40.209 0 0 1 1.456-.817c.553-.307 1.133-.67 1.7-1.002.571-.326 1.09-.683 1.522-.982.43-.3.769-.548.945-.708-.251.17-.507.334-.762.5a50.109 50.109 0 0 0 .817-.55c-.012.013-.035.033-.055.05 5.924-4.046 10.97-9.362 14.75-15.422 3.799-6.056 6.27-12.886 7.294-19.833-.222 2.786-.732 5.011-1.378 6.964zM95.14 29.419zm-4.578-6.88a50.051 50.051 0 0 1 4.212 7.777c.136.297.263.599.39.901 2.689 6.586 3.912 13.65 3.733 20.61.046-2.303-.107-4.604-.362-6.887-.29-2.63-.823-5.229-1.53-7.77-1.389-5.098-3.644-9.929-6.506-14.333.263.363.54.756.827 1.174a17.787 17.787 0 0 1 .861 1.334l-.345-.6-.374-.585-.746-1.169c-.509-.771-1.06-1.515-1.59-2.271-.576-.723-1.121-1.47-1.72-2.173-.453-.517-.887-1.05-1.347-1.56 1.622 1.71 3.144 3.543 4.497 5.552zM52.498.624c.795.043 1.592.12 2.388.18.652.054 1.302.15 1.944.223.193.009.397.022.653.05.255.036.56.101.958.192 2.964.494 5.667 1.237 7.587 2.004a54.47 54.47 0 0 1 10.219 5.132c3.11 2 5.9 4.274 8.261 6.758 1.088 1.18.77.923.17.35l.901.956c-.398-.398-.79-.801-1.195-1.19l-1.247-1.133c.304.266 1.04.901 1.542 1.367a50.693 50.693 0 0 0-13.75-9.972C65.86 3.046 60.401 1.506 54.944.89a18.5 18.5 0 0 0 1.716.13c-.588-.069-1.177-.163-1.774-.217C54.085.75 53.285.68 52.49.64L50.127.585c.782 0 1.575.02 2.371.04z"
        /><path
          xmlns="http://www.w3.org/2000/svg"
          d="m62.824 100.075.23-.068c-.241.065-.479.137-.722.199.164-.042.33-.082.492-.131zm24.102-20.883c2.295-3.027 4.323-6.644 5.617-9.76l-.015.003a46.898 46.898 0 0 1-15.259 19.368 86.22 86.22 0 0 0 3.478-2.549c1.462-1.528 3.908-4.013 6.18-7.062zM19.155 88.24c3.886 3.474 8.572 6.498 13.789 8.534 2.034.766 4.11 1.437 6.233 1.91 1.053.271 2.129.44 3.196.64.535.094 1.077.147 1.614.223.539.07 1.076.149 1.619.18-2.449-.271-4.88-.678-7.246-1.322a50.272 50.272 0 0 1-6.919-2.41 52.776 52.776 0 0 1-6.445-3.422 52.373 52.373 0 0 1-5.841-4.333zm47.968 6.194-1.202.472-1.228.41c-.813.292-1.65.51-2.487.743.84-.211 1.686-.408 2.506-.68L65.949 95l1.208-.441c-.047-.024-.322.03-.034-.126zM52.93 97.515c-.629.053-1.26.048-1.893.055-.633.008-1.267.021-1.902-.02l.854.08c.262.016.497.036.702.06.748-.063 1.491-.081 2.239-.175zm-25.056-5.828c.726.426 1.498.801 2.264 1.215.191.106.54.225.975.385-.932-.4-1.826-.897-2.734-1.358-.45-.239-.882-.506-1.324-.756-.44-.251-.878-.502-1.294-.783l.508.34.53.316 1.075.64z"
        />
      </g>
      <g>
        <g xmlns="http://www.w3.org/2000/svg" transform="matrix(.08974 0 0 .08974 19.09 20.09)">
          <path d="M-1-1h702v702H-1z" style="fill:none" />
        </g>
        <g xmlns="http://www.w3.org/2000/svg" transform="matrix(.08974 0 0 .08974 19.09 20.09)">
          <path d="M222 158.3c-31 .7-57.5 21-79.5 60.8-23.1 44.8-34.5 94.6-34.3 149.4.4 6.6 1.1 7.2 2.2 1.9 9.3-40.3 19-71.8 29.1-94.6 9.9-22.9 20.9-41.7 32.9-56.2 27.6-32.1 51.5-37.3 71.8-15.6 22.2 25.6 34 68.8 35.4 129.4-1.2 81.5-11.9 143.1-32.1 185-25.3 51-51.3 68-77.7 50.8-36-28.7-56-92.3-60-190.6-1.4-3.4-2.7-.9-3.7 7.5-1.9 10.2-3.2 21.4-4 33.3-3 53.4 4.1 98.7 21.2 135.9 17.5 35.3 40.8 53.2 69.9 53.8 31.4-.5 60-21 85.9-61.7 25.8-42.5 42.4-94.3 49.7-155.6 2.7-65.2-6.1-120.7-26.3-166.5-20.4-43.6-47.1-66-80-67.2" /><path d="M452 134.1c-16.1-26.4-46.9-39.3-92.4-38.5-50.3 2.4-99.2 17.4-146.6 45-5.5 3.6-5.7 4.6-.6 2.9 39.6-12.1 71.7-19.5 96.4-22.1 24.8-2.9 46.5-2.8 65.1.4 41.6 7.9 58.1 26 49.4 54.4-11.1 32-42.6 63.8-94.4 95.4-71.2 39.7-129.9 61.3-176.2 64.7-56.9 3.6-84.5-10.4-82.8-41.9C77 248.8 122 199.7 205.1 147c2.2-2.9-.6-2.7-8.3.6-9.8 3.5-20.1 7.9-30.9 13.2-47.7 24.1-83.5 52.9-107.1 86.3-21.8 32.8-25.7 62-11.7 87.4 16.1 26.9 48.2 41.4 96.4 43.5 49.7 1.1 102.9-10.4 159.6-34.8 57.8-30.3 101.5-65.6 131-106 27.6-39.5 33.6-73.8 18.2-102.9" /><path d="M588 321.2c14.8-27.2 10.6-60.3-12.9-99.3-27.3-42.4-64.7-77.2-112.3-104.4-5.9-3-6.8-2.7-2.8.9 30.3 28.2 52.7 52.4 67.4 72.4 14.9 20.1 25.7 38.9 32.2 56.6 14 40 6.5 63.3-22.4 69.9-33.3 6.4-76.5-5-129.8-34-69.9-41.8-118-81.9-144.2-120.2-31.5-47.5-33.2-78.4-5.1-92.7C301 53.6 366 68.1 453.2 113.8c3.6.4 2.1-1.9-4.7-6.9-7.9-6.8-16.9-13.5-26.9-20.2-44.7-29.3-87.5-45.8-128.3-49.6-39.3-2.5-66.5 8.7-81.6 33.6-15.3 27.4-11.8 62.5 10.5 105.2 23.9 43.6 60.5 83.9 109.9 120.8 55.1 34.9 107.6 55.1 157.3 60.4 48 4.1 80.8-7.8 98.2-35.7" /><path d="M494 532.5c31-.7 57.5-21 79.5-60.8 23.1-44.8 34.5-94.6 34.3-149.4-.4-6.6-1.1-7.2-2.2-1.9-9.3 40.3-19 71.8-29.1 94.6-9.9 22.9-20.9 41.7-32.9 56.2-27.6 32.1-51.5 37.3-71.8 15.6-22.2-25.6-34-68.8-35.4-129.4 1.2-81.5 11.9-143.1 32.1-185 25.3-51 51.3-68 77.7-50.8 36 28.7 56 92.3 60 190.6 1.4 3.4 2.7.9 3.7-7.5 1.9-10.2 3.2-21.4 4-33.3 3-53.4-4.1-98.7-21.2-135.9-17.5-35.3-40.8-53.2-69.9-53.8-31.4.5-60 21-85.9 61.7-25.8 42.5-42.4 94.3-49.7 155.6-2.7 65.2 6.1 120.7 26.3 166.5 20.4 43.6 47.1 66 80 67.2" /><path d="M128 369.6c-14.8 27.2-10.6 60.3 12.9 99.3 27.3 42.4 64.7 77.2 112.3 104.4 5.9 3 6.8 2.7 2.8-.9-30.3-28.2-52.7-52.4-67.4-72.4-14.9-20.1-25.7-38.9-32.2-56.6-14-40-6.5-63.3 22.4-69.9 33.3-6.4 76.5 5 129.8 34 69.9 41.8 118 81.9 144.2 120.2 31.5 47.5 33.2 78.4 5.1 92.7C415 637.2 350 622.7 262.8 577c-3.6-.4-2.1 1.9 4.7 6.9 7.9 6.8 16.9 13.5 26.9 20.2 44.7 29.3 87.5 45.8 128.3 49.6 39.3 2.5 66.5-8.7 81.6-33.6 15.3-27.4 11.8-62.5-10.5-105.2-23.9-43.6-60.5-83.9-109.9-120.8-55.1-34.9-107.6-55.1-157.3-60.4-48-4.1-80.8 7.8-98.2 35.7" /><path d="M264 556.7c16.1 26.4 46.9 39.3 92.4 38.5 50.3-2.4 99.2-17.4 146.6-45 5.5-3.6 5.7-4.6.6-2.9-39.6 12.1-71.7 19.5-96.4 22.1-24.8 2.9-46.5 2.8-65.1-.4-41.6-7.9-58.1-26-49.4-54.4 11.1-32 42.6-63.8 94.4-95.4 71.2-39.7 129.9-61.3 176.2-64.7 56.9-3.6 84.5 10.4 82.8 41.9-6.9 45.5-51.9 94.6-135.1 147.3-2.2 2.9.6 2.7 8.3-.6 9.8-3.5 20.1-7.9 30.9-13.2 47.7-24.1 83.5-52.9 107.1-86.3 21.8-32.8 25.7-62 11.7-87.4-16.1-26.9-48.2-41.4-96.3-43.5-49.7-1.1-102.9 10.4-159.6 34.8-57.8 30.3-101.5 65.6-131 106-27.6 39.5-33.6 73.8-18.2 102.9" />
        </g>
      </g>
      <path d="m151.955 35.908-12.918 30.79h-5.325L121 35.908h4.87l10.525 25.755 10.608-25.755h4.952zm32.4 15.189q0-3.302-1.692-5.985-1.61-2.6-4.395-4.086t-6.047-1.486q-3.385 0-6.17 1.527t-4.355 4.169q-1.61 2.765-1.61 6.15 0 3.22 1.734 5.943 1.65 2.56 4.437 4.066t6.026 1.506 6.026-1.568 4.395-4.21q1.651-2.766 1.651-6.026zm4.458.247q0 4.458-2.311 8.214-2.23 3.59-6.047 5.716t-8.234 2.126q-4.582 0-8.42-2.229-3.756-2.146-5.902-5.902-2.229-3.838-2.229-8.42 0-4.416 2.353-8.13 2.228-3.55 6.046-5.635T172.262 35q4.499 0 8.337 2.188 3.756 2.146 5.944 5.82 2.27 3.838 2.27 8.336zm11.433 15.354h-4.416v-30.79h4.416v30.79zm15.23-26.25V62.2h6.975q2.89 0 5.2-1.485 2.188-1.445 3.426-3.88t1.239-5.324q0-3.013-1.177-5.531t-3.363-4.004q-2.353-1.527-5.407-1.527h-6.893zm-6.852 0-1.98-4.54h15.683q4.086 0 7.471 2.105 3.26 2.022 5.16 5.53t1.898 7.636q0 3.096-1.218 6.13t-3.364 5.303q-2.063 2.229-4.416 3.178-2.27.908-5.407.908H211.06v-26.25h-2.436z" />
    </svg>
    """
  end
end
